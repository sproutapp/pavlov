# Pavlov
[![Build Status](https://travis-ci.org/sproutapp/pavlov.svg?branch=master)](https://travis-ci.org/sproutapp/pavlov)
[![Inline docs](http://inch-ci.org/github/sproutapp/pavlov.svg?branch=master&style=flat)](http://inch-ci.org/github/sproutapp/pavlov)

A BDD framework for your Elixir projects. It's main goal is to provide a rich, expressive syntax for you to develop your unit tests against. Think of it as RSpec's little Elixir-loving brother.

Pavlov is an abstraction built on top of the excellent ExUnit, Elixir's standard testing library, so all of its standard features are still supported.

Here's a short and sweet example of Pavlov in action:

```elixir
defmodule OrderSpec do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

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

## Table Of Contents

- [Usage](#usage)
- [Describe and Context](#describe-and-context)
- [Let](#let)
- [Subject](#subject)
- [Expects syntax](#expects-syntax)
- [Included Matchers](#included-matchers)
- [Callbacks](#callbacks)
  - [before(:each)](#beforeeach)
  - [before(:all)](#beforeall)
- [Mocking](#mocking)
	- [Mocks with arguments](#mocks-with-arguments)
- [Skipping tests](#skipping-tests)
	- [xit](#xit)
	- [xdescribe/xcontext](#xdescribexcontext)
- [Development](#development)
	- [Running the tests](#running-the-tests)
	- [Building the docs](#building-the-docs)
- [Contributing](#contributing)

## Usage
Add Pavlov as a dependency in your `mix.exs` file:

```elixir
defp deps do
  [{:pavlov, ">= 0.1.0", only: :test}]
end
```

After you are done, run `mix deps.get` in your shell to fetch the dependencies.
To start execution of your Pavlov tests, add the following to your 'test/test_helper.exs':

```elixir
Pavlov.start
```

Afterwards, running `mix test` in your shell will run all test suites.

## Describe and Context
You may use the `describe` and `context` constructs to group tests together in a logical way. Although `context` is just an alias for `describe`, you may use it to add some extra meaning to your tests, ie. you can use `contexts` within a `described` module function to simulate different conditions under which your function should work.

## Let
You can use `let` to define memoized helper methods for your tests. The returning value is cached across all invocations. 'let' is lazily-evaluated, meaning that its body is not evaluated until the first time the method is invoked.

```elixir
let :order do
  %Order{items: [
    {"burger", 10.0}
    {"fries", 5.2}
  ]}
end
```

## Subject
You can use `subject` to explicitly define the value that is returned by the subject method in the example scope. A subject declared in a context will be available in child contexts as well.

```elixir
describe "Array" do
  subject do
    [1, 2, 3]
  end

  it "has the prescribed elements" do
    assert subject == [1, 2, 3]
  end

  context "Inner context" do
    it "can use an outer-scope subject" do
      assert subject == [1, 2, 3]
    end
  end
end
```

If you are using [Expects syntax](#expects-syntax) together with `subject`, you can use the `is_expected` helper:

```elixir
describe "Numbers" do
  subject do: 5

  context "straight up, no message" do
    it is_expected |> to_eq 5
  end

  context "you can also use a custom message" do
    it "is equal to 5" do
      is_expected |> to_eq 5
    end
  end
end
```

By default, every created context via `describe` or `context` contains a `subject` that returns `nil`.

## Expects syntax

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

Visit the [Pavlov Wiki](https://github.com/sproutapp/pavlov/wiki/Included-Matchers)
to learn more about all of the core matchers available for your tests.

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
describe "before :all" do
  before :all do
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
  allow HTTPotion |> to_receive(get: fn(url) -> "<html></html>" end)
end

it "gets a page" do
  result = HTTPotion.get("http://example.com")

  expect HTTPotion |> to_have_received :get
  expect result |> to_eq "<html></html>"
end
```

If you want the mock to retain all other functions in the original module,
then you will need to pass the `opts` `List` argument to the `allow` function
and include the `:passthrough` value. The `allow` function specifies a default
`opts` `List` that includes the `:no_link` value. This value should be included
in the `List` as it ensures that the mock (which is linked to the creating
process) will unload automatically when a crash occurs.

```elixir
before :each do
  allow(HTTPotion, [:no_link, :passthrough]) |> to_receive(get: fn(url) -> "<html></html>" end)
end
```

Expectations on mocks also work using `asserts` syntax via the `called` matcher:

```elixir
before :each do
  allow HTTPotion |> to_receive(get: fn(url) -> "<html></html>" end)
end

it "gets a page" do
  HTTPotion.get("http://example.com")

  assert called HTTPotion.get
end
```

### Mocks with arguments
You can also perform assertions on what arguments were passed to a mocked
method:

```elixir
before :each do
  allow HTTPotion |> to_receive(get: fn(url) -> "<html></html>" end)
end

it "gets a page" do
  HTTPotion.get("http://example.com")

  expect HTTPotion |> to_have_received :get |> with_args "http://example.com"
end
```

In `asserts` syntax:

```elixir
before :each do
  allow HTTPotion |> to_receive (get: fn(url) -> url end )
end

it "gets a page" do
  HTTPotion.get("http://example.com")

  assert called HTTPotion.get("http://example.com")
end
```

## Skipping tests
Pavlov runs with the `--exclude pending:true` configuration by default, which
means that tests tagged with `:pending` will not be run.

Pavlov offers several convenience methods to skip your tests, BDD style:

### xit
Marks a specific test as pending and will not run it.

```elixir
xit "does not run" do
  # This will never run
end
```

### xdescribe/xcontext
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

## Development

After cloning the repo, make sure to download all dependencies using `mix deps.get`.
Pavlov is tested using Pavlov itself, so the general philosophy is to simply write a test using a given feature until it passes.

### Running the tests
Simply run `mix test`

### Building the docs
Run `MIX_ENV=docs mix docs`. The resulting HTML files will be output to the `docs` folder.

## Contributing

1. Fork it ( https://github.com/sproutapp/pavlov/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
