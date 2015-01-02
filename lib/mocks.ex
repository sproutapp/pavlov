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

  def allow(module, opts \\ [:no_link]) do
    :meck.new(module, opts)

    # Unload the module once the test exits
    on_exit fn ->
      :meck.unload(module)
    end

    module
  end

  def to_receive(module, mock) do

    if is_list mock do
      {method, value} = hd(mock)
    else
      method  = mock
      value   = fn -> nil end
    end

    :meck.expect(module, method, value)

    {module, method, value}
  end

end
