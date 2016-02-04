defmodule Pavlov.Mocks.Matchers do
  @moduledoc """
  Provides matchers for Mocked modules.
  """

  import ExUnit.Assertions
  import Pavlov.Mocks.Matchers.Messages

  @doc """
  Asserts whether a method was called with on a mocked module.
  Use in conjunction with `with` to perform assertions on the arguments
  passed in to the method.

  A negative version `not_to_have_received` is also provided. The same usage
  instructions apply.

  ## Example
      expect HTTPotion |> to_have_received :get
  """
  def to_have_received(module, tuple) when is_tuple(tuple) do
    {method, args} = tuple
    args = List.flatten [args]
    result = _called(module, method, args)

    case result do
      false -> flunk message_for_matcher(:have_received, [module, method, args], :assertion)
      _ -> assert result
    end
  end
  def to_have_received(module, method) do
    result = _called(module, method, [])

    case result do
      false -> flunk message_for_matcher(:have_received, [module, method], :assertion)
      _ -> assert result
    end
  end

  @doc false
  def not_to_have_received(module, tuple) when is_tuple(tuple) do
    {method, args} = tuple
    args = List.flatten [args]
    result = _called(module, method, args)

    case result do
      true -> flunk message_for_matcher(:have_received, [module, method, args], :refutation)
      _ -> refute result
    end
  end
  def not_to_have_received(module, method) do
    result = _called(module, method, [])

    case result do
      true -> flunk message_for_matcher(:have_received, [module, method], :refutation)
      _ -> refute result
    end
  end

  @doc """
  Use in conjunction with `to_have_received` to perform assertions on the
  arguments passed in to the given method.

  ## Example
      expect HTTPotion |> to_have_received :get |> with_args "http://example.com"
  """
  def with_args(method, args) do
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
