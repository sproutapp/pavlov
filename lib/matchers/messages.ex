defmodule Pavlov.Matchers.Messages do
  @moduledoc false

  @doc false
  def message_for_matcher(matcher_name, [actual, expected], :assertion) do
    actual = inspect actual
    expected = inspect expected

    case matcher_name do
      :eq -> "Expected #{actual} to equal #{expected}"
      :have_key -> "Expected #{actual} to have key #{expected}"
      :include -> "Expected #{actual} to include #{expected}"
      :have_raised -> "Expected function to have raised #{expected}"
      :have_thrown -> "Expected function to have thrown #{expected}"
      _ -> "Assertion with #{matcher_name} failed: #{actual}, #{expected}"
    end
  end
  def message_for_matcher(matcher_name, [actual], :assertion) do
    actual = inspect actual

    case matcher_name do
      :be_true -> "Expected #{actual} to be true"
      :be_truthy -> "Expected #{actual} to be truthy"
      :be_falsey -> "Expected #{actual} to be falsey"
      :be_nil -> "Expected #{actual} to be nil"
      :be_empty -> "Expected #{actual} to be empty"
      :have_exited -> "Expected function to have exited"
      _ -> "Assertion with #{matcher_name} failed: #{actual}"
    end
  end
  def message_for_matcher(matcher_name, [actual, expected], :refutation) do
    actual = inspect actual
    expected = inspect expected

    case matcher_name do
      :eq -> "Expected #{actual} not to equal #{expected}"
      :have_key -> "Expected #{actual} not to have key #{expected}"
      :include -> "Expected #{actual} not to include #{expected}"
      :have_raised -> "Expected function not to have raised #{expected}"
      :have_thrown -> "Expected function not to have thrown #{expected}"
      _ -> "Refutation with #{matcher_name} failed: #{actual}, #{expected}"
    end
  end
  def message_for_matcher(matcher_name, [actual], :refutation) do
    actual = inspect actual

    case matcher_name do
      :be_true -> "Expected #{actual} not to be true"
      :be_truthy -> "Expected #{actual} not to be truthy"
      :be_falsey -> "Expected #{actual} not to be falsey"
      :be_nil -> "Expected #{actual} not to be nil"
      :be_empty -> "Expected #{actual} not to be empty"
      :have_exited -> "Expected function not to have exited"
      _ -> "Refutation with #{matcher_name} failed: #{actual}"
    end
  end

end
