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

      @stack []
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
  defmacro it(description, var \\ quote(do: _), contents) do
    quote do
      defit Enum.join(@stack, "") <> unquote(description), unquote(var) do
        unquote(contents)
      end
    end
  end

  @doc """
  You can nest your tests under a descriptive name.
  Tests can be infinitely nested.
  """
  defmacro describe(description, _ \\ quote(do: _), contents) do
    quote do
      @stack Enum.concat(@stack, [unquote(description) <> ", "])
      # Closure the old stack so we can use it in defmodule
      oldStack = Enum.concat @stack, []

      # Defines a new module per describe, thus scoping .let
      defmodule Module.concat(__MODULE__, unquote(description)) do
        use ExUnit.Case
        @stack oldStack

        unquote(contents)
      end

      # Cleans context stack
      if Enum.count(@stack) > 0 do
        @stack Enum.take(@stack, Enum.count(@stack) - 1)
      end
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
      def unquote(name)(), do: unquote(contents[:do])
    end
  end

  @doc false
  defmacro defit(message, var \\ quote(do: _), contents) do
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
      ExUnit.Case.__on_definition__(__ENV__, message)

      def unquote(message)(unquote(var)), do: unquote(contents)
    end
  end
end
