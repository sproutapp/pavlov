defmodule PavlovMocksTest do
  use Pavlov.Case, async: true
  use Pavlov.Mocks
  import Pavlov.Syntax.Expect
  import Fixtures.Mockable

  describe "Mocks" do
    describe ".to_have_received" do
      it "asserts that a simple mock was called" do
        allow(Fixtures.Mockable) |> to_receive(do_something: fn -> :error end)

        result = Fixtures.Mockable.do_something()

        expect Fixtures.Mockable |> to_have_received :do_something
        expect result |> to_eq(:error)
      end

      it "provides a flunk message" do
        message = message_for_matcher(:have_received, [Fixtures.Mockable, :do_something], :assertion)

        expect message
          |> to_eq "Expected Elixir.Fixtures.Mockable to have received :do_something"
      end
    end

    describe ".not_to_have_received" do
      it "refutes that a mock was called" do
        allow(Fixtures.Mockable) |> to_receive(do_something: fn -> :error end)

        expect Fixtures.Mockable |> not_to_have_received :do_something
      end

      it "provides a flunk message" do
        message = message_for_matcher(:have_received, [Fixtures.Mockable, :do_something], :refutation)

        expect message
          |> to_eq "Expected Elixir.Fixtures.Mockable not to have received :do_something"
      end

      context "when used with argument expectations" do
        it "provides a flunk message" do
          message = message_for_matcher(:have_received, [Fixtures.Mockable, :do_something, [1]], :refutation)

          expect message
            |> to_eq "Expected Elixir.Fixtures.Mockable not to have received :do_something with [1]"
        end
      end
    end

    it "resets mocks" do
      expect Fixtures.Mockable.do_something |> to_eq({:ok, "did something"})
    end

    it "permits chaining to_receive" do
      allow(Fixtures.Mockable)
        |> to_receive(do_something: fn -> :error end)
        |> to_receive(do_something_else: fn -> :success end)

      result = Fixtures.Mockable.do_something()
      other_result = Fixtures.Mockable.do_something_else()

      expect Fixtures.Mockable |> to_have_received :do_something
      expect result |> to_eq(:error)

      expect Fixtures.Mockable |> to_have_received :do_something_else
      expect other_result |> to_eq(:success)
    end

    it "doesn't permit the mock to retain other functions in module" do
      allow(Fixtures.Mockable)
        |> to_receive(do_something: fn -> :success end)

        expect fn -> Fixtures.Mockable.do_something_else end |> to_have_raised UndefinedFunctionError
    end

    context "when the :passthrough option is used" do
      it "permits the mock to retain other functions in the module" do
        allow(Fixtures.Mockable, [:no_link, :passthrough])
          |> to_receive(do_something: fn -> :success end)

          expect fn -> Fixtures.Mockable.do_something_else end |> not_to_have_raised UndefinedFunctionError
      end
    end
  end

  context "Stubbing" do
    it "Can return nil when stubbing" do
      allow(Fixtures.Mockable) |> to_receive(:do_something)

      result = Fixtures.Mockable.do_something()

      expect Fixtures.Mockable |> to_have_received :do_something
      expect result |> to_be_nil
    end

    it "allows setting expectations matching method and arguments" do
      allow(Fixtures.Mockable) |> to_receive(do_with_args: fn(_) -> :ok end )

      Fixtures.Mockable.do_with_args("a string")

      expect Fixtures.Mockable |> to_have_received :do_with_args |> with_args "a string"
    end

    it "allows setting expectations matching method and several arguments" do
      allow(Fixtures.Mockable) |> to_receive(do_with_several_args: fn(_, _) -> :ok end )

      Fixtures.Mockable.do_with_several_args(1, 2)

      expect Fixtures.Mockable |> to_have_received :do_with_several_args |> with_args [:_, 2]
    end

    it "allows mocking with arguments to return something" do
      allow(Fixtures.Mockable) |> to_receive(do_with_args: fn(_) -> :error end )

      result = Fixtures.Mockable.do_with_args("a string")

      expect Fixtures.Mockable |> to_have_received :do_with_args |> with_args "a string"
      expect result |> to_eq :error
    end

    it "provides a flunk message" do
      message = message_for_matcher(:have_received, [Fixtures.Mockable, :do_with_args, [1]], :assertion)

      expect message
        |> to_eq "Expected Elixir.Fixtures.Mockable to have received :do_with_args with_args [1]"
    end
  end

  context "Callbacks" do
    before :each do
      allow(Fixtures.Mockable) |> to_receive(do_something: fn -> :error end)
      :ok
    end

    it "supports mocking at setup time" do
      result = Fixtures.Mockable.do_something()

      expect Fixtures.Mockable |> to_have_received :do_something
      expect result |> to_eq(:error)
    end

    context "Across contexts" do
      it "supports mocking across contexts" do
        result = Fixtures.Mockable.do_something()

        expect Fixtures.Mockable |> to_have_received :do_something
        expect result |> to_eq(:error)
      end

      context "When an existing mock is re-mocked" do
        before :each do
          allow(Fixtures.Mockable) |> to_receive(do_something: fn -> :ok end)
          :ok
        end

        it "uses the re-mock" do
          result = Fixtures.Mockable.do_something()

          expect Fixtures.Mockable |> to_have_received :do_something
          expect result |> to_eq(:ok)
        end
      end
    end
  end

  context "Using asserts syntax" do
    describe ".called" do
      it "works for simple mocks" do
        allow(Fixtures.Mockable) |> to_receive(do_something: fn -> :error end)

        Fixtures.Mockable.do_something()

        assert called Fixtures.Mockable.do_something
      end

      it "works for mocks with arguments" do
        allow(Fixtures.Mockable) |> to_receive(do_with_args: fn(_) -> :ok end)

        Fixtures.Mockable.do_with_args("a string")

        assert called Fixtures.Mockable.do_with_args("a string")
      end
    end
  end
end
