defmodule PavlovExpectTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  describe "Matchers" do
    describe ".eq" do
      it "compares based on equality" do
        expect 1 |> to_eq 1
      end
    end

    describe ".be_true" do
      it "compares against 'true'" do
        expect (1==1) |> to_be_true
      end
    end

    describe ".be_truthy" do
      it "compares based on truthiness" do
        expect 1 |> to_be_truthy
        expect true |> to_be_truthy
        expect "pavlov" |> to_be_truthy
      end
    end
  end
end
