defmodule Pavlov.Mocks.Matchers do
  import ExUnit.Assertions

  def to_have_received(module, tuple) when is_tuple(tuple) do
    {method, args} = tuple
    assert _called(module, method, List.flatten [args])
  end
  def to_have_received(module, method) do
    assert _called(module, method, [])
  end

  def not_to_have_received(module, tuple) when is_tuple(tuple) do
    {method, args} = tuple
    refute _called(module, method, List.flatten [args])
  end
  def not_to_have_received(module, method) do
    refute _called(module, method, [])
  end

  def with(method, args) do
    {method, args}
  end

  defmacro called({ {:., _, [ module , f ]} , _, args }) do
    quote do
      :meck.called unquote(module), unquote(f), unquote(args)
    end
  end

  defp _called(module, f, args) do
    :meck.called module, f, args
  end

end
