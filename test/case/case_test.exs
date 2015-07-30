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

  xdescribe "A skipped describe" do
    it "is never run" do
      assert 1 + 3 == 2
    end

    describe "A normal Context inside a skipped describe" do
      it "is never run" do
        assert 1 + 3 == 2
      end
    end
  end

  xcontext "A skipped Context" do
    it "is never run" do
      assert 1 + 3 == 2
    end

    context "A normal Context inside a skipped Context" do
      it "is never run" do
        assert 1 + 3 == 2
      end
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
      Agent.update(:memoized_let, fn acc -> 0 end)
      something
      something

      assert Agent.get(:memoized_let, fn acc -> acc end) == 1
    end

    context "Scoping" do
      let :outer_something do
        "I come from an enclosing context"
      end

      let :outer_something_else do
        "I also come from an enclosing context"
      end

      context "Inner .let" do
        let :inner_something do
          "I come from a deeper context"
        end

        it "allows accessing letted functions from enclosing contexts" do
          assert outer_something == "I come from an enclosing context"
          assert outer_something_else == "I also come from an enclosing context"
        end

        context "An even deeper context" do
          let :inner_something do
            "I come from this context"
          end

          it "allows accessing letted functions from depply enclosing contexts" do
            assert outer_something == "I come from an enclosing context"
          end

          it "allows redefining a letted function" do
            assert inner_something == "I come from this context"
          end
        end
      end

      it "does not leak letted functions from deeper contexts" do
        fns = __MODULE__.__info__(:functions)
        assert fns[:inner_something] == nil
      end
    end
  end

  describe ".subject" do
    subject do: 5

    it "allows the usage of a subject method" do
      assert subject == 5
    end

    context "Inner .subject" do
      it "uses the outer scope's subject method" do
        assert subject == 5
      end
    end
  end
end
