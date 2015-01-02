defmodule Pavlov.Mocks.Matchers do
  import ExUnit.Assertions

  def to_have_received(module, method) do
    {method, args} = parse_method method
    assert _called(module, method, args)
  end

  def not_to_have_received(module, method) do
    {method, args} = parse_method method
    refute _called(module, method, args)
  end

  def with(method, args) do
    {method, args}
  end

  defmacro called({ {:., _, [ module , f ]} , _, args }) do
    quote do
      :meck.called unquote(module), unquote(f), unquote(args)
    end
  end

  defp _called(module, f, args \\ []) do
    :meck.called module, f, args
  end

  defp parse_method(tuple) do
    args = []
    method = tuple

    if is_tuple tuple do
      {method, args} = tuple
    end

    {method, List.flatten [args]}
  end

end
