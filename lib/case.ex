defmodule Pavlov.Case do
  @moduledoc """
  Use this module to prepare other modules for testing.

  ## Example
      defmodule MySpec do
        use Pavlov.Case
        it "always passes" do
          assert true
        end
      end
  """

  @doc false
  defmacro __using__(opts \\ []) do
    async  = Keyword.get(opts, :async, false)

    quote do
      use ExUnit.Case, async: unquote(async)
      use Pavlov.Callbacks
      use Pavlov.Mocks

      @stack []
      @pending false

      Agent.start(fn -> %{} end, name: :pavlov_let_defs)
      Agent.start(fn -> %{} end, name: :pavlov_subject_defs)

      import Pavlov.Case
      import Pavlov.Syntax.Sugar
    end
  end

  @doc """
  The cornerstone BDD macro, "it" allows your test to be defined
  via a string.

  ## Example
      it "is the truth" do
        assert true == true
      end
  """
  defmacro it(contents) do
    quote do
      it "is expected", do: unquote(contents)
    end
  end
  defmacro it(desc, var \\ quote(do: _), contents) do
    quote do
      message = Enum.join(@stack, "") <> unquote(desc)

      defit message, unquote(var), @pending do
        unquote(contents)
      end
    end
  end

  @doc """
  Allows you specify a pending test, meaning that it is never run.

  ## Example
      xit "is the truth" do
        # This will never run
        assert true == true
      end
  """
  defmacro xit(description, var \\ quote(do: _), contents) do
    quote do
      defit Enum.join(@stack, "") <> unquote(description), unquote(var), true do
        unquote(contents)
      end
    end
  end

  @doc """
  You can nest your tests under a descriptive name.
  Tests can be infinitely nested.
  """
  defmacro describe(desc, _ \\ quote(do: _), pending \\ false, contents) do
    quote do
      @stack Enum.concat(@stack, [unquote(desc) <> ", "])
      # Closure the old stack so we can use it in defmodule
      old_stack = Enum.concat @stack, []
      pending   = @pending || unquote(pending)

      # Defines a new module per describe, thus scoping .let
      defmodule Module.concat(__MODULE__, unquote(desc)) do
        use ExUnit.Case

        @stack old_stack
        @pending pending

        def subject, do: nil
        defoverridable [subject: 0]

        # Redefine enclosing let definitions in this module
        Agent.get(:pavlov_callback_defs, fn dict ->
          Stream.filter dict, fn {module, _name} ->
            sub_module? module, __MODULE__
          end
        end)
          |> Stream.map(fn {_module, {periodicity, context, fun}} ->
            quote do
              use Pavlov.Mocks
              before(unquote(periodicity), unquote(context), do: unquote(fun))
            end
          end)
          |> Enum.each(&Module.eval_quoted(__MODULE__, &1))

        unquote(contents)

        # Redefine enclosing let definitions in this module
        Agent.get(:pavlov_let_defs, fn dict ->
          Stream.filter dict, fn {module, lets} ->
            sub_module? module, __MODULE__
          end
        end)
          |> Stream.flat_map(fn {_module, lets} ->
            Stream.map lets, fn ({name, fun}) ->
              quote do: let(unquote(name), do: unquote(fun))
            end
          end)
          |> Enum.each(&Module.eval_quoted(__MODULE__, &1))

        # Redefine enclosing subject definitions in this module
        Agent.get(:pavlov_subject_defs, fn dict ->
          Stream.filter dict, fn {module, _subjects} ->
            sub_module? module, __MODULE__
          end
        end)
          |> Stream.flat_map(fn {_module, subjects} ->
            Stream.map subjects, fn (fun) ->
              quote do: subject(unquote(fun))
            end
          end)
          |> Enum.each(&Module.eval_quoted(__MODULE__, &1))
      end

      # Cleans context stack
      if Enum.count(@stack) > 0 do
        @stack Enum.take(@stack, Enum.count(@stack) - 1)
      end
    end
  end

  @doc """
  Defines a group of tests as pending.
  Any other contexts nested within an xdescribe will not run
  as well.
  """
  defmacro xdescribe(desc, _ \\ quote(do: _), contents) do
    quote do
      describe unquote(desc), _, true, unquote(contents)
    end
  end

  @doc """
  Allows lazy initialization of subjects for your tests.
  Subjects created via "let" will never leak into other
  contexts (defined via "describe" or "context"), not even
  those who are children of the context where the lazy subject
  is defined.

  Example:
      let :lazy do
        "oh so lazy"
      end

      it "lazy initializes" do
        assert lazy == "oh so lazy"
      end
  """

  defmacro let(name, contents) do
    quote do
      require Pavlov.Utils.Memoize, as: Memoize
      Memoize.defmem unquote(name)(), do: unquote(contents[:do])

      defoverridable [{unquote(name), 0}]

      Agent.update(:pavlov_let_defs, fn(map) ->
        new_let = {unquote(Macro.escape name), unquote(Macro.escape contents[:do])}

        Dict.put map, __MODULE__, (map[__MODULE__] || []) ++ [new_let]
      end)
    end
  end

  @doc """
  You can use `subject` to explicitly define the value
  that is returned by the subject method in the example
  scope. A subject declared in a context will be available
  in child contexts as well.

  Example:
      describe "Array" do
        subject do
          [1, 2, 3]
        end

        it "has the prescribed elements" do
          assert subject == [1, 2, 3]
        end

        context "Inner context" do
          it "can use an outer-scope subject" do
            assert subject == [1, 2, 3]
          end
        end
      end
  """

  defmacro subject(contents) do
    contents = Macro.escape(contents)

    quote bind_quoted: binding do
      def subject do
        Macro.expand(unquote(contents), __MODULE__)[:do]
      end

      defoverridable [subject: 0]

      Agent.update(:pavlov_subject_defs, fn(map) ->
        Dict.put map, __MODULE__, (map[__MODULE__] || []) ++ [contents]
      end)
    end
  end

  @doc false
  defmacro defit(message, var \\ quote(do: _), pending \\ false, contents) do
    contents =
      case contents do
        [do: _] ->
          quote do
            unquote(contents)
            :ok
          end
        _ ->
          quote do
            try(unquote(contents))
            :ok
          end
        end

    var      = Macro.escape(var)
    contents = Macro.escape(contents, unquote: true)

    quote bind_quoted: binding do
      message = :"#{message}"
      Pavlov.Case.__on_definition__(__ENV__, message, pending)

      def unquote(message)(unquote(var)) do
        unquote(contents)
        Pavlov.Utils.Memoize.flush
      end
    end
  end

  @doc false
  def __on_definition__(env, name, pending \\ false) do
    mod   = env.module
    tags  = Module.get_attribute(mod, :tag) ++ Module.get_attribute(mod, :moduletag)
    if pending do tags = tags ++ [:pending] end
    tags = tags |> normalize_tags |> Map.merge(%{line: env.line, file: env.file})

    Module.put_attribute(mod, :ex_unit_tests,
    %ExUnit.Test{name: name, case: mod, tags: tags})

    Module.delete_attribute(mod, :tag)
  end

  @doc false
  def sub_module?(child, parent) do
    String.starts_with? "#{parent}", "#{child}"
  end

  defp normalize_tags(tags) do
    Enum.reduce Enum.reverse(tags), %{}, fn
      tag, acc when is_atom(tag) -> Map.put(acc, tag, true)
      tag, acc when is_list(tag) -> Dict.merge(acc, tag)
    end
  end
end
