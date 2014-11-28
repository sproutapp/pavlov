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
end
