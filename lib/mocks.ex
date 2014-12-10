defmodule Pavlov.Mocks do
  @moduledoc """
  Use this module to mock methods on a given module

  ## Example
    defmodule MySpec do
      use Pavlov.Mocks
    end
  """

  import ExUnit.Callbacks

  defmacro __using__(_) do
    quote do
      import Pavlov.Mocks
      import Pavlov.Mocks.Matchers
    end
  end

  def allow(module, opts \\ [:passthrough, :no_link,]) do
    :meck.new(module, opts)

    # Unload the module once the test exits
    on_exit fn ->
      :meck.unload(module)
    end

    module
  end

  def to_receive(module, method) do
    :meck.expect(module, method, fn -> nil end)

    {module, method}
  end

  def and_return(tuple, returnable) do
    :meck.delete(elem(tuple, 0), elem(tuple, 1), fn -> nil end)

    :meck.expect(elem(tuple, 0), elem(tuple, 1), fn -> returnable end)
  end

end
