defmodule PavlovExpectTest do
  use Pavlov.Case, async: true

  describe "Matchers" do
    describe ".eq" do
      it "compares based on equality" do
        assert eq(1, 1)
      end
    end
  end
end
