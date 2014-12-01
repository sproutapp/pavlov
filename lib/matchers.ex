defmodule Pavlov.Matchers do
  @moduledoc """
  Provides several matcher functions.
  Matchers accept up to two values, `actual` and `expected`,
  and return a Boolean.
  """

  @type t :: list | map

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
    be_true(1==1) # => true
    be_true("a"=="b") # => false
  """
  @spec be_true(any) :: boolean
  def be_true(exp) do
    exp == true
  end

  @doc """
  Performs a truthy check with a given expression.

  Example:
    be_truthy(1) # => true
    be_truthy("a") # => true
    be_truthy(nil) # => false
    be_truthy(false) # => false
  """
  @spec be_truthy(any) :: boolean
  def be_truthy(exp) do
    exp
  end

  @doc """
  Performs a falsey check with a given expression.

  Example:
  be_falsey(1) # => false
  be_falsey("a") # => false
  be_falsey(nil) # => true
  be_falsey(false) # => true
  """
  @spec be_falsey(any) :: boolean
  def be_falsey(exp) do
    !exp
  end

  @doc """
  Performs a nil check with a given expression.

  Example:
  be_nil(nil) # => true
  be_nil("a") # => false
  """
  @spec be_nil(any) :: boolean
  def be_nil(exp) do
    exp == nil
  end

  @doc """
  Performs has_key? operation on a Dict.

  Example:
    have_key(%{:a => 1}, :a) # => true
    have_key(%{:a => 1}, :b) # => false
  """
  @spec have_key(node, t) :: boolean
  def have_key(key, dict) do
    Dict.has_key? dict, key
  end

  @doc """
  Checks if a Dict is empty

  Example:
    be_empty(%{}) # => true
    be_empty(%{:a => 1}) # => false
  """
  @spec be_empty(t|char_list) :: boolean
  def be_empty(list) do
    cond do
      is_bitstring(list)            -> String.length(list) == 0
      is_list(list) || is_map(list) -> Enum.empty? list
      true                          -> false
    end
  end

  @doc """
  Tests whether a given value is part of an array

  Example:
    include([1, 2, 3], 1) # => true
    include([1], 2) # => false
  """
  @spec include(any, list|char_list) :: boolean
  def include(member, list) do
    cond do
      is_bitstring(list)            -> String.contains? list, member
      is_list(list) || is_map(list) -> Enum.member? list, member
      true                          -> false
    end
  end

end
