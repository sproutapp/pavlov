defmodule Pavlov do
  def start do
    Pavlov.Utils.Memoize.ResultTable.start_link
    ExUnit.start
  end
end
