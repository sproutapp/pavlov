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
  defmacro it(desc, var \\ quote(do: _), contents) do
    quote do
      defit Enum.join(@stack, "") <> unquote(desc), unquote(var), @pending do
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

        # Redefine enclosing let definitions in this module
        Agent.get(:pavlov_callback_defs, fn dict ->
          Stream.filter dict, fn {module, _name} ->
            String.starts_with?("#{__MODULE__}", "#{module}") && "#{__MODULE__}" != "#{module}"
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
          Stream.filter dict, fn {module, _name} ->
            String.starts_with? "#{__MODULE__}", "#{module}"
          end
        end)
          |> Stream.map(fn {_module, {name, fun}} ->
            quote do: let(unquote(name), do: unquote(fun))
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

      Agent.update(:pavlov_let_defs, fn(map) ->
        Dict.put_new map, __MODULE__, {unquote(Macro.escape name), unquote(Macro.escape contents[:do])}
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
        Pavlov.Utils.Memoize.flush
        unquote(contents)
      end
    end
  end

  @doc false
  def __on_definition__(env, name, pending \\ false) do
    mod   = env.module
    tags  = Module.get_attribute(mod, :tag) ++ Module.get_attribute(mod, :moduletag)
    if pending do tags = [tags|[:pending]] end
    tags  = tags |> normalize_tags |> Map.merge(%{line: env.line, file: env.file})

    Module.put_attribute(mod, :ex_unit_tests,
    %ExUnit.Test{name: name, case: mod, tags: tags})

    Module.delete_attribute(mod, :tag)
  end

  defp normalize_tags(tags) do
    Enum.reduce Enum.reverse(tags), %{}, fn
    tag, acc when is_atom(tag) -> Map.put(acc, tag, true)
    tag, acc when is_list(tag) -> Dict.merge(acc, tag)
    end
  end
end
