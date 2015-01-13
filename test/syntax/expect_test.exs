defmodule PavlovExpectTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect
  import Pavlov.Matchers.Messages

  describe "Matchers" do
    describe ".eq" do
      it "compares based on equality" do
        expect 1 |> to_eq 1
      end

      it "supports a negative expression" do
        expect 1 |> not_to_eq 2
      end

      it "provides a flunk message" do
        message = message_for_matcher(:eq, [2, 1], :assertion)

        expect message
          |> to_eq "Expected 2 to equal 1"
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:eq, [2, 2], :refutation)

        expect message
          |> to_eq "Expected 2 not to equal 2"
      end
    end

    describe ".be_true" do
      it "compares against 'true'" do
        expect (1==1) |> to_be_true
      end

      it "supports a negative expression" do
        expect (1==2) |> not_to_be_true
      end

      it "provides a flunk message" do
        message = message_for_matcher(:be_true, [false], :assertion)

        expect message
          |> to_eq "Expected false to be true"
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:be_true, [true], :refutation)

        expect message
          |> to_eq "Expected true not to be true"
      end
    end

    describe ".be_truthy" do
      it "compares based on truthiness" do
        expect 1 |> to_be_truthy
        expect true |> to_be_truthy
        expect "pavlov" |> to_be_truthy
      end

      it "supports a negative expression" do
        expect false |> not_to_be_truthy
        expect nil |> not_to_be_truthy
      end

      it "provides a flunk message" do
        message = message_for_matcher(:be_truthy, [nil], :assertion)

        expect message
          |> to_eq "Expected nil to be truthy"
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:be_truthy, [nil], :refutation)

        expect message
          |> to_eq "Expected nil not to be truthy"
      end
    end

    describe ".be_falsey" do
      it "compares based on falseyness" do
        expect false |> to_be_falsey
        expect nil |> to_be_falsey
      end

      it "supports a negative expression" do
        expect 1 |> not_to_be_falsey
        expect true |> not_to_be_falsey
        expect "pavlov" |> not_to_be_falsey
      end

      it "provides a flunk message" do
        message = message_for_matcher(:be_falsey, [false], :assertion)

        expect message
          |> to_eq "Expected false to be falsey"
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:be_falsey, [false], :refutation)

        expect message
          |> to_eq "Expected false not to be falsey"
      end
    end

    describe ".be_nil" do
      it "compares against nil" do
        expect nil |> to_be_nil
      end

      it "supports a negative expression" do
        expect "nil" |> not_to_be_nil
      end

      it "provides a flunk message" do
        message = message_for_matcher(:be_nil, [nil], :assertion)

        expect message
          |> to_eq "Expected nil to be nil"
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:be_nil, [nil], :refutation)

        expect message
          |> to_eq "Expected nil not to be nil"
      end
    end

    describe ".have_key" do
      it "returns true if a dict has a key" do
        expect %{:a => 1} |> to_have_key :a
        expect [a: 1] |> to_have_key :a
      end

      it "supports a negative expression" do
        expect %{:a => 1} |> not_to_have_key :b
        expect [a: 1] |> not_to_have_key :b
      end

      it "provides a flunk message" do
        message = message_for_matcher(:have_key, [%{:a => 1}, :b], :assertion)

        expect message
          |> to_eq "Expected %{a: 1} to have key :b"
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:have_key, [%{:a => 1}, :b], :refutation)

        expect message
          |> to_eq "Expected %{a: 1} not to have key :b"
      end
    end

    describe ".be_empty" do
      it "returns true if a dict is empty" do
        expect %{} |> to_be_empty
        expect [] |> to_be_empty
      end

      it "returns true if a string is empty" do
        expect "" |> to_be_empty
      end

      it "supports a negative expression" do
        expect %{:a => 1} |> not_to_be_empty
        expect [a: 1] |> not_to_be_empty
        expect "asd" |> not_to_be_empty
      end

      it "provides a flunk message" do
        message = message_for_matcher(:be_empty, [%{:a => 1}], :assertion)

        expect message
          |> to_eq "Expected %{a: 1} to be empty"
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:be_empty, [%{:a => 1}], :refutation)

        expect message
          |> to_eq "Expected %{a: 1} not to be empty"
      end
    end

    describe ".include" do
      it "returns true if a member is in the List" do
        expect [1, 2, 3] |> to_include 2
      end

      it "works with maps using tuple notation" do
        expect %{:a => 1} |> to_include {:a, 1}
      end

      it "works with strings and partial strings" do
        expect "a string" |> to_include "a stri"
      end

      it "supports a negative expression" do
        expect [1, 2, 3] |> not_to_include 5
        expect %{:a => 1} |> not_to_include {:a, 5}
        expect "a string" |> not_to_include "a strict"
      end

      it "provides a flunk message" do
        message = message_for_matcher(:include, [%{:a => 1}, %{:a => 5}], :assertion)

        expect message
          |> to_eq "Expected %{a: 1} to include %{a: 5}"
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:include, [%{:a => 1}, %{:a => 5}], :refutation)

        expect message
          |> to_eq "Expected %{a: 1} not to include %{a: 5}"
      end
    end

    describe ".have_raised" do
      it "returns true if a given function raised a given exception" do
        expect fn -> 1 + "test" end |> to_have_raised ArithmeticError
      end

      it "supports a negative expression" do
        expect fn -> 1 + 2 end |> not_to_have_raised ArithmeticError
      end

      it "provides a flunk message" do
        message = message_for_matcher(:have_raised, [fn -> 1 + "test" end, ArithmeticError], :assertion)

        expect message
          |> to_eq "Expected function to have raised ArithmeticError"
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:have_raised, [fn -> 1 + "test" end, ArithmeticError], :refutation)

        expect message
          |> to_eq "Expected function not to have raised ArithmeticError"
      end
    end

    describe ".have_thrown" do
      it "returns true if a given function threw a given value" do
        expect fn -> throw("x") end |> to_have_thrown "x"
      end

      it "supports a negative expression" do
        expect fn -> throw("x") end |> not_to_have_thrown "y"
      end

      it "provides a flunk message" do
        message = message_for_matcher(:have_thrown, [fn -> 1 + throw("x") end, "x"], :assertion)

        expect message
          |> to_eq "Expected function to have thrown \"x\""
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:have_thrown, [fn -> 1 + throw("x") end, "x"], :refutation)

        expect message
          |> to_eq "Expected function not to have thrown \"x\""
      end
    end

    describe ".have_exited" do
      it "returns true if a given function exited" do
        expect fn -> exit "bye!" end |> to_have_exited
      end

      it "supports a negative expression" do
        expect fn -> :ok end |> not_to_have_exited
      end

      it "provides a flunk message" do
        message = message_for_matcher(:have_exited, [fn -> exit "bye!" end], :assertion)

        expect message
          |> to_eq "Expected function to have exited"
      end

      it "provides a refutation flunk message" do
        message = message_for_matcher(:have_exited, [fn -> exit "bye!" end], :refutation)

        expect message
          |> to_eq "Expected function not to have exited"
      end
    end
  end
end
