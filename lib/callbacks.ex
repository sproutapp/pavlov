defmodule Pavlov.Callbacks do
  import ExUnit.Callbacks

  defmacro before(:each, context \\ quote(do: _), contents) do
    quote do
      setup unquote(context), do: unquote(contents)[:do]
    end
  end
end
