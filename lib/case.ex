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
      import Pavlov.Case
    end
  end

  import ExUnit.Case

  @doc """
  The cornerstone BDD macro, "it" allows your test to be defined
  via a string.

  ## Example
    it "is the truth" do
      assert true == true
    end
  """
  defmacro it(message, var \\ quote(do: _), contents) do
    contents = Macro.escape(contents, unquote: true)
    var      = Macro.escape(var)

    quote bind_quoted: binding do
      test = :"It #{message}"
      ExUnit.Case.__on_definition__(__ENV__, test)

      def unquote(test)(unquote(var)), do: unquote(contents)
    end
  end
end
