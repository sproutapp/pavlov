defmodule PavlovCaseTest do
  use Pavlov.Case, async: true

  it "is the truth" do
    assert 1 + 1 == 2
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
    let :something do
      "I am a string"
    end

    it "allows lazy definitions" do
      fns = __MODULE__.__info__(:functions)
      assert fns[:something] != nil
      assert something == "I am a string"
    end

    context "Scoping" do
      it "does not leak letted functions through contexts" do
        fns = __MODULE__.__info__(:functions)
        assert fns[:something] == nil
      end
    end
  end
end
