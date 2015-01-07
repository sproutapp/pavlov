defmodule Fixtures.Mockable do
  @doc false
  def do_something do
    {:ok, "did something"}
  end

  @doc false
  def do_something_else do
    {:ok, "did something else"}
  end

  @doc false
  def do_with_args(arg) do
    arg
  end
end
