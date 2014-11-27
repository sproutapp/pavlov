pavlov
======

A BDD framework for your Elixir projects.

Tentative, fantasy-land usage:

```elixir
defmodule OrderSpec do
  use Pavlov.Case, async: true

  describe ".sum" do
    context "When the Order has items" do
      let(:order, fn -> %Order{items: [
          {"burger", 10.0}
          {"fries", 5.2}
        ]} end)

      it "sums the prices of its items" do
        should Order.sum(order) == 15.2
      end
    end
  end
end
```
