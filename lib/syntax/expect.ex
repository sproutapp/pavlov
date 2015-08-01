defmodule Pavlov.Syntax.Expect do
  @moduledoc """
  Expect syntax for writing better specs.
  """

  import ExUnit.Assertions
  import Pavlov.Matchers.Messages

  @doc """
  Sets an expectation on a value.
  In this example, `eq` is a typical matcher:

  ## Example
      expect(actual) |> to_eq(expected)
  """
  def expect({fun, context, args}, module) do
    contents = {fun, context, args}

    quote do
      Module.eval_quoted(unquote(module), unquote(contents))
    end
  end
  def expect(subject) do
    subject
  end

  # Dynamically defines methods for included matchers, such that:
  # For a given matcher `eq`, defines a method `to_eq`.
  Enum.each Pavlov.Matchers.__info__(:functions), fn({method, _}) ->
    method_name = :"to_#{method}"

    @doc false
    def unquote(method_name)(expected, actual \\ nil) do
      args = case actual do
        nil -> [expected]
        _ -> [actual, expected]
      end

      result = apply(Pavlov.Matchers, unquote(method), args)

      case result do
        false -> flunk message_for_matcher(unquote(:"#{method}"), args, :assertion)
        _ -> assert result
      end
    end
  end

  # Dynamically defines methods for included matchers, such that:
  # For a given matcher `eq`, defines a method `not_to_eq`.
  Enum.each Pavlov.Matchers.__info__(:functions), fn({method, _}) ->
    method_name = :"not_to_#{method}"

    @doc false
    def unquote(method_name)(expected, actual \\ nil) do
      args = case actual do
        nil -> [expected]
        _ -> [actual, expected]
      end

      result = apply(Pavlov.Matchers, unquote(method), args)

      case result do
        true -> flunk message_for_matcher(unquote(:"#{method}"), args, :refutation)
        _ -> refute result
      end
    end
  end
end
