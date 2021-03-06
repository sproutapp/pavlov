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

      context "With a Nested context" do
        it "runs the callback before the test", context do
          expect context |> to_have_key :hello
          expect context[:hello] |> to_eq "world"
        end
      end

      context "without :ok, {:ok, dict}" do
        before :each do
          :something_other_than_ok
        end
        it "does not error", _context do
          :ok
        end
      end
    end

    describe "before :all" do
      before :all do
        {:ok, [context: :setup_all]}
      end

      it "runs the callback before all tests", context do
        expect context[:context] |> to_eq :setup_all
      end

      context "With a Nested context" do
        it "runs the callback before the test", context do
          expect context[:context] |> to_eq :setup_all
        end
      end

      context "without :ok, {:ok, dict}" do
        before :all do
          :something_other_than_ok
        end
        it "does not error", _context do
          :ok
        end
      end
    end
  end
end
