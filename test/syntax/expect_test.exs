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

    describe ".be_falsey" do
      it "compares based on falseyness" do
        expect false |> to_be_falsey
        expect nil |> to_be_falsey
      end
    end

    describe ".be_nil" do
      it "compares against nil" do
        expect nil |> to_be_nil
      end
    end

    describe ".have_key" do
      it "returns true if a dict has a key" do
        expect %{:a => 1} |> to_have_key :a
        expect [a: 1] |> to_have_key :a
      end
    end

    describe ".be_empty" do
      it "returns true if a dict is empty" do
        expect %{} |> to_be_empty
        expect [] |> to_be_empty
      end
    end
  end
end
