# Pavlov

A BDD framework for your Elixir projects.

Simple usage:

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

## Included Matchers

When using the `expects` syntax, all matchers have negative counterparts, ie:
```elixir
expect 1 |> not_to_eq 2
expect(1 > 5) |> not_to_be_true
```

### eq
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

### be_true
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

### be_truthy
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

### be_falsey
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

### be_nil
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

### have_key
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

### be_empty
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


### include
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
