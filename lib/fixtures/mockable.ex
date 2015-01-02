defmodule Fixtures.Mockable do
  def do_something do
    {:ok, "did something"}
  end

  def do_with_args(arg) do
    arg
  end
end
