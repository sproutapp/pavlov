defmodule Pavlov.Syntax.Expect do
  @moduledoc """
  Expect syntax for writing better specs.

  In this example, `eq` is a typical matcher
  ## Example
    expect(actual).to eq(expected)
  """

  import ExUnit.Assertions

  @doc false
  def expect(subject) do
    subject
  end

  # Dynamically defines methods for included matchers, such that:
  # For a given matcher `eq`, defines a method `to_eq`.
  Enum.each Pavlov.Matchers.__info__(:functions), fn({method, _}) ->
    method_name = :"to_#{method}"

    def unquote(method_name)(expected, actual \\ nil) do
      args = case actual do
        nil -> [expected]
        _ -> [actual, expected]
      end

      assert apply(Pavlov.Matchers, unquote(method), args)
    end
  end

  # Dynamically defines methods for included matchers, such that:
  # For a given matcher `eq`, defines a method `not_to_eq`.
  Enum.each Pavlov.Matchers.__info__(:functions), fn({method, _}) ->
    method_name = :"not_to_#{method}"

    def unquote(method_name)(expected, actual \\ nil) do
      args = case actual do
        nil -> [expected]
        _ -> [actual, expected]
      end

      assert !(apply(Pavlov.Matchers, unquote(method), args))
    end
  end
end
