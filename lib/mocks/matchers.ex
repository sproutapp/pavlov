defmodule Pavlov.Mocks.Matchers do
  @moduledoc """
  Provides matchers for Mocked modules.
  """

  import ExUnit.Assertions

  @doc """
  Asserts whether a method was called with on a mocked module.
  Use in conjunction with `with` to perform assertions on the arguments
  passed in to the method.

  ## Example
      expect HTTPotion |> to_have_received :get
  """
  def to_have_received(module, tuple) when is_tuple(tuple) do
    {method, args} = tuple
    assert _called(module, method, List.flatten [args])
  end
  def to_have_received(module, method) do
    assert _called(module, method, [])
  end

  @doc false
  def not_to_have_received(module, tuple) when is_tuple(tuple) do
    {method, args} = tuple
    refute _called(module, method, List.flatten [args])
  end
  def not_to_have_received(module, method) do
    refute _called(module, method, [])
  end

  @doc """
  Use in conjunction with `to_have_received` to perform assertions on the
  arguments passed in to the given method.

  ## Example
      expect HTTPotion |> to_have_received :get |> with "http://example.com"
  """
  def with(method, args) do
    {method, args}
  end

  @doc """
  Asserts whether a method was called when using "Asserts" syntax:

  ## Example
      assert called HTTPotion.get("http://example.com")
  """
  defmacro called({ {:., _, [ module , f ]} , _, args }) do
    quote do
      :meck.called unquote(module), unquote(f), unquote(args)
    end
  end

  defp _called(module, f, args) do
    :meck.called module, f, args
  end

end
