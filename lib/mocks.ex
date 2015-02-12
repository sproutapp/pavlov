defmodule Pavlov.Mocks do
  @moduledoc """
  Use this module to mock methods on a given module.

  ## Example
    defmodule MySpec do
      use Pavlov.Mocks

      describe "My Tests" do
        ...
      end
    end
  """

  alias __MODULE__

  defstruct module: nil

  import ExUnit.Callbacks

  defmacro __using__(_) do
    quote do
      import Pavlov.Mocks
      import Pavlov.Mocks.Matchers
      import Pavlov.Mocks.Matchers.Messages
    end
  end

  @doc """
  Prepares a module for stubbing. Used in conjunction with
  `.to_receive`.

  ## Example
      allow MyModule |> to_receive(...)
  """
  def allow(module, opts \\ [:no_link]) do
    try_unloading module

    :meck.new(module, opts)

    # Unload the module once the test exits
    on_exit fn ->
      try_unloading module
    end

    %Mocks{module: module}
  end

  @doc """
  Mocks a function on a module. Used in conjunction with
  `allow`.

  ## Example
      allow MyModule |> to_receive(get: fn(url) -> "<html></html>" end)

  For a method that takes no arguments and returns nil, you may use a
  simpler syntax:
      allow MyModule |> to_receive(:simple_method)
  """
  def to_receive(struct = %Mocks{module: module}, mock) when is_list mock do
    {mock, value} = hd(mock)
    :meck.expect(module, mock, value)
    struct
  end
  def to_receive(struct = %Mocks{module: module}, mock) do
    value = fn -> nil end
    :meck.expect(module, mock, value)
    struct
  end

  @doc false
  defp try_unloading(module) do
    try do
      :meck.unload module
    rescue
      _ -> :ok
    end
  end

end
