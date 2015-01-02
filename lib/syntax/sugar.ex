defmodule Pavlov.Syntax.Sugar do
  @moduledoc """
  Provides an alternative DSL for BDD methods.
  """

  for describe_alias <- [:context] do
    defmacro unquote(describe_alias)(description, var \\ quote(do: _), contents) do
      quote do
        Pavlov.Case.describe(unquote(description), unquote(var), unquote(contents))
      end
    end
  end

  for xdescribe_alias <- [:xcontext] do
    defmacro unquote(xdescribe_alias)(description, var \\ quote(do: _), contents) do
      quote do
        Pavlov.Case.xdescribe(unquote(description), unquote(var), unquote(contents))
      end
    end
  end

end
