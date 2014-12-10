defmodule Pavlov.Mocks.Matchers do
  #import Mock
  import ExUnit.Assertions

  def to_have_received(module, method) do
    assert called(module, method)
  end

  def not_to_have_received(module, method) do
    refute called(module, method)
  end

  defp called(module, f, args \\ []) do
    :meck.called module, f, args
  end

end
