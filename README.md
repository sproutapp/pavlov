# Pavlov

A BDD framework for your Elixir projects.

Here's the TL;DR; example:

```elixir
defmodule OrderSpec do
  use Pavlov.Case, async: true

  describe ".sum" do
    context "When the Order has items" do
      let :order do
        %Order{items: [
          {"burger", 10.0}
          {"fries", 5.2}
        ]}
      end

      it "sums the prices of its items" do
        expect Order.sum(order) |> to_eq 15.2
      end
    end
  end
end
```

## `Describe` and `Context`
You may use the `describe` and `context` constructs to group tests together in a logical way. Although `context` is just an alias for `describe`, you may use it to add some extra meaning to your tests, ie. you can use `contexts` within a `described` module function to simulate different conditions under which your function should work.

## `Expects` syntax

You may use the regular ExUnit `assert` syntax if you wish, but Pavlov includes
an `expect` syntax that makes your tests more readable.

If you wish to use this syntax, simply import the `Pavlov.Syntax.Expect` at the
beginning of your Test module:

```elixir
defmodule MyTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect
  #...
end
```

All core matchers are supported under both syntaxes.

## Included Matchers

When using the `expects` syntax, all matchers have negative counterparts, ie:
```elixir
expect 1 |> not_to_eq 2
expect(1 > 5) |> not_to_be_true
```

### `eq`
In `asserts` syntax:
```elixir
#passes if actual == expected
assert eq(1, 1)
```

In `expects` syntax:
```elixir
#passes if actual == expected
expect 1 |> to_eq 1
```

### `be_true`
In `asserts` syntax:
```elixir
#passes if expected == true
assert be_true(1 > 0)
```

In `expects` syntax:
```elixir
#passes if expected == true
expect(1 > 0) |> to_be_true
```

### `be_truthy`
In `asserts` syntax:
```elixir
#passes if expected is truthy
assert be_truthy("something")
```

In `expects` syntax:
```elixir
#passes if expected is truthy
expect "something" |> to_be_truthy
```

### `be_falsey`
In `asserts` syntax:
```elixir
#passes if expected is falsey
assert be_falsey(false)
```

In `expects` syntax:
```elixir
#passes if expected is falsey
expect false |> to_be_falsey
```

### `be_nil`
In `asserts` syntax:
```elixir
#passes if expected is nil
assert be_nil(nil)
```

In `expects` syntax:
```elixir
#passes if expected is nil
expect nil |> to_be_nil
```

### `have_key`
In `asserts` syntax:
```elixir
#passes if Dict has member as a key
assert have_key(%{:a => 1}, :a)
```

In `expects` syntax:
```elixir
#passes if Dict has member as a key
expect %{:a => 1} |> to_have_key :a
```

### `be_empty`
In `asserts` syntax:
```elixir
#passes if Dict is empty
assert be_empty(%{})
```

In `expects` syntax:
```elixir
#passes if Dict is empty
expect %{} |> to_be_empty
```

####It also works with Lists:

In `asserts` syntax:
```elixir
#passes if Dict is empty
assert be_empty([])
```

In `expects` syntax:
```elixir
#passes if Dict is empty
expect [] |> to_be_empty
```

####And Strings:

In `asserts` syntax:
```elixir
#passes if Dict is empty
assert be_empty("")
```

In `expects` syntax:
```elixir
#passes if Dict is empty
expect "" |> to_be_empty
```

### `include`
In `asserts` syntax:
```elixir
#passes if List includes member
assert include([1, 2], 1)
  ```

In `expects` syntax:
```elixir
#passes if List includes member
expect [1, 2] |> to_include 1
```

####It also works with Maps:

In `asserts` syntax:
```elixir
#passes if Map includes member
assert include(%{:a => 1, :b => 2}, {:a, 1})
```

In `expects` syntax:
```elixir
#passes if Map includes member
expect %{:a => 1, :b => 2} |> to_include {:a, 1}
```

####And even Strings:

In `asserts` syntax:
```elixir
#passes if String contains partial
assert include("a string", "a stri")
```

In `expects` syntax:
```elixir
#passes if String contains partial
expect "a string" |> to_include "a_stri"
```

## Callbacks
For now, Pavlov only supports callbacks that run before test cases. [ExUnit's
`on_exit` callback](http://elixir-lang.org/docs/stable/ex_unit/ExUnit.Callbacks.html#on_exit/2) is still fully supported though, and may be used normally inside your `before` callbacks.

### before(:each)
Runs the specified code before every test case.

```elixir
describe "before :each" do
  before :each do
    IO.puts "A test is about to start"
    :ok
  end

  it "does something" do
    #...
  end

  it "does something else" do
    #...
  end
end
```

In this case, `"A test is about to start"` is printed twice to the console.

### before(:all)
Runs the specified code once before any tests run.

```elixir
describe "before :each" do
  before :each do
    IO.puts "This suite is about to run"
    :ok
  end

  it "does something" do
    #...
  end

  it "does something else" do
    #...
  end
end
```
In this case, `"This suite is about to run"` is printed once to the console.

## Mocking
Pavlov provides facilities to mock functions in your Elixir modules. This is
achieved using [Meck](https://github.com/eproxus/meck), an erlang mocking tool.

Here's a simple example using [HTTPotion](https://github.com/myfreeweb/httpotion):

```elixir
before :each do
  allow HTTPotion |> to_receive :get |> and_return "<html></html>"
end

it "gets a page" do
  result = HTTPotion.get("http://example.com")

  expect HTTPotion |> to_have_received :get
  expect result |> to_eq "<html></html>"
end
```

Expectations on mocks also work using `asserts` syntax via the `called` matcher:

```elixir
before :each do
  allow HTTPotion |> to_receive :get |> and_return "<html></html>"
end

it "gets a page" do
  HTTPotion.get("http://example.com")

  assert called HTTPotion.get
end
```

## Skipping tests
Pavlov runs with the `--exclude pending:true` configuration by default, which
means that tests tagged with `:pending` will not be run.

Pavlov offers several convenience methods to skip your tests, BDD style:

### `xit`
Marks a specific test as pending and will not run it.

```elixir
xit "does not run" do
  # This will never run
end
```

### `xdescribe/xcontext`
Marks a group of tests as pending and will not run them. Just as `describe`
and `context`, `xdescribe` and `xcontext` are analogous.

```elixir
xdescribe "A pending group" do
  it "does not run" do
    # This will never run
  end

  it "does not run either" do
    # This will never run either
  end
end
```
