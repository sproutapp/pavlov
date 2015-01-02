defmodule PavlovMocksTest do
  use Pavlov.Case, async: true
  use Pavlov.Mocks
  import Pavlov.Syntax.Expect
  import Fixtures.Mockable
  alias Fixtures.Mockable, as: Mockable

  describe "Mocks" do
    describe ".to_have_received" do
      it "asserts that a simple mock was called" do
        allow(Mockable) |> to_receive(do_something: fn -> :error end)

        result = Mockable.do_something()

        expect Mockable |> to_have_received :do_something
        expect result |> to_eq(:error)
      end
    end

    describe ".not_to_have_received" do
      it "refutes that a mock was called" do
        allow(Mockable) |> to_receive(do_something: fn -> :error end)

        expect Mockable |> not_to_have_received :do_something
      end
    end

    it "resets mocks" do
      expect Mockable.do_something |> to_eq({:ok, "did something"})
    end
  end

  context "Stubbing" do
    it "Can return nil when stubbing" do
      allow(Mockable) |> to_receive(:do_something)

      result = Mockable.do_something()

      expect Mockable |> to_have_received :do_something
      expect result |> to_be_nil
    end

    it "allows setting expectations matching method and arguments" do
      allow(Mockable) |> to_receive(do_with_args: fn(_) -> :ok end )

      Mockable.do_with_args("a string")

      expect Mockable |> to_have_received :do_with_args |> with "a string"
    end

    it "allows mocking with arguments to return something" do
      allow(Mockable) |> to_receive(do_with_args: fn(_) -> :error end )

      result = Mockable.do_with_args("a string")

      expect Mockable |> to_have_received :do_with_args |> with "a string"
      expect result |> to_eq :error
    end
  end

  context "Callbacks" do
    before :each do
      allow(Mockable) |> to_receive(do_something: fn -> :error end)
      :ok
    end

    it "supports mocking at setup time" do
      result = Mockable.do_something()

      expect Mockable |> to_have_received :do_something
      expect result |> to_eq(:error)
    end

    # Mocking across contexts will not work
    # until callbacks also work across contexts :(
    context "Across contexts" do
      xit "supports mocking across contexts" do
        result = Mockable.do_something()

        expect Mockable |> to_have_received :do_something
        expect result |> to_eq(:error)
      end
    end
  end

  context "Using asserts syntax" do
    describe ".called" do
      it "works for simple mocks" do
        allow(Mockable) |> to_receive(do_something: fn -> :error end)

        Mockable.do_something()

        assert called Mockable.do_something
      end

      it "works for mocks with arguments" do
        allow(Mockable) |> to_receive(do_with_args: fn(_) -> :ok end)

        Mockable.do_with_args("a string")

        assert called Mockable.do_with_args("a string")
      end
    end
  end
end
