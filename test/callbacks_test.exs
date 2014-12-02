defmodule PavlovCallbackTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  describe "Callbacks" do
    describe "before :each" do
      before :each do
        {:ok, hello: "world"}
      end

      it "runs the callback before the first test", context do
        expect context |> to_have_key :hello
        expect context[:hello] |> to_eq "world"
      end

      it "runs the callback before the second test", context do
        expect context |> to_have_key :hello
        expect context[:hello] |> to_eq "world"
      end
    end

    describe "before :all" do
      before :all do
        {:ok, [context: :setup_all]}
      end

      it "runs the callback before all tests", context do
        expect context[:context] |> to_eq :setup_all
      end

    end
  end
end
