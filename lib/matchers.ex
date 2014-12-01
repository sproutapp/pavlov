defmodule Pavlov.Matchers do
  @moduledoc """
  Provides several matcher functions.
  Matchers accept two values, `actual` and `expected`, and return a Boolean
  """

  @doc """
  Performs an equality test between two values using ==.

  Example:
    eq(1, 2) # => false
    eq("a", "a") # => true
  """
  @spec eq(any, any) :: boolean
  def eq(actual, expected) do
    actual == expected
  end

  @doc """
  Performs an equality test between a given expression and 'true'.

  Example:
    be_true(nil, 1==1) # => true
    be_true(nil, "a"=="b") # => false
  """
  @spec be_true(any, any) :: boolean
  def be_true(_, exp) do
    exp == true
  end
end
