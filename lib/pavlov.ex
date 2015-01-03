defmodule Pavlov do
  @moduledoc """
  The main Pavlov module.
  """

  @doc """
  Starts execution of the test suites.
  """
  def start do
    Pavlov.Utils.Memoize.ResultTable.start_link
    ExUnit.start [exclude: :pending]
  end
end
