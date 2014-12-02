defmodule Pavlov.Callbacks do
  import ExUnit.Callbacks

  defmacro before(periodicity \\ :each, context \\ quote(do: _), contents)
  defmacro before(:each, context, contents) do
    quote do
      setup unquote(context), do: unquote(contents)[:do]
    end
  end

  defmacro before(:all, context, contents) do
    quote do
      setup_all unquote(context), do: unquote(contents)[:do]
    end
  end

end
