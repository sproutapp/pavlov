defmodule Pavlov.Syntax.Sugar do
  @moduledoc """
  Provides an alternative DSLs for BDD methods.
  """

  for describe_alias <- [:context] do
    defmacro unquote(describe_alias)(description, var \\ quote(do: _), contents) do
      quote do
        Pavlov.Case.describe(unquote(description), unquote(var), unquote(contents))
      end
    end
  end

end
