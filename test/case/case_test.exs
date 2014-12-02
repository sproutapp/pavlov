defmodule PavlovCaseTest do
  use Pavlov.Case, async: true, trace: true

  it "is the truth" do
    assert 1 + 1 == 2
  end

  xit "doesn't run this test" do
    assert false
  end

  describe "Context" do
    it "allows nesting" do
      assert 1 + 1 == 2
    end

    context "With multiple levels" do
      it "also allows nesting" do
        assert 1 + 1 == 2
      end
    end
  end

  describe "Another Context" do
    it "allows nesting" do
      assert 1 + 1 == 2
    end
  end

  describe ".let" do
    setup_all do
      Agent.start_link(fn -> 0 end, name: :memoized_let)
      :ok
    end

    let :something do
      Agent.update(:memoized_let, fn acc -> acc + 1 end)
      "I am a string"
    end

    it "allows lazy definitions" do
      fns = __MODULE__.__info__(:functions)
      assert fns[:something] != nil
      assert something == "I am a string"
    end

    it "only invokes the letted block once" do
      something
      something

      assert Agent.get(:memoized_let, fn acc -> acc end) == 1
    end

    context "Scoping" do
      it "does not leak letted functions through contexts" do
        fns = __MODULE__.__info__(:functions)
        assert fns[:something] == nil
      end
    end
  end
end
