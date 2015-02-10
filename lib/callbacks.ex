defmodule Pavlov.Callbacks do
  @moduledoc """
  Allows running tasks in-between test executions.
  Currently only supports running tasks before tests are
  executed.

  ## Context
  If you return `{:ok, <dict>}` from `before :all`, the dictionary will be merged
  into the current context and be available in all subsequent setup_all,
  setup and the test itself.

  Similarly, returning `{:ok, <dict>}` from `before :each`, the dict returned
  will be merged into the current context and be available in all subsequent
  setup and the test itself.

  Returning `:ok` leaves the context unchanged in both cases.
  """

  import ExUnit.Callbacks

  @doc false
  defmacro __using__(opts \\ []) do
    quote do
      Agent.start(fn -> %{} end, name: :pavlov_callback_defs)

      import Pavlov.Callbacks
    end
  end

  @doc false
  defmacro before(periodicity \\ :each, context \\ quote(do: _), contents)

  @doc """
  Runs before each **test** in the current context is executed or before
  **all** tests in the context are executed.

  Example:
      before :all do
        IO.puts "Test batch started!"
        :ok
      end

      before :each do
        IO.puts "Here comes a new test!"
        :ok
      end
  """
  defmacro before(:each, context, contents) do
    quote do
      setup unquote(context), do: unquote(contents)[:do]

      Agent.update :pavlov_callback_defs, fn(map) ->
        Dict.put_new map, __MODULE__, {:each, unquote(Macro.escape context), unquote(Macro.escape contents[:do])}
      end
    end
  end
  defmacro before(:all, context, contents) do
    quote do
      setup_all unquote(context), do: unquote(contents)[:do]

      Agent.update :pavlov_callback_defs, fn(map) ->
        Dict.put_new map, __MODULE__, {:all, unquote(Macro.escape context), unquote(Macro.escape contents[:do])}
      end
    end
  end

end
