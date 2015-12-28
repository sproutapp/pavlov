defmodule Pavlov.Mocks.Matchers.Messages do
  @moduledoc false

  @doc false
  def message_for_matcher(matcher_name, [module, method], :assertion) do
    method = inspect method

    case matcher_name do
      :have_received -> "Expected #{module} to have received #{method}"
    end
  end
  def message_for_matcher(matcher_name, [module, method, args], :assertion) do
    method = inspect method
    args = inspect args

    case matcher_name do
      :have_received -> "Expected #{module} to have received #{method} with_args #{args}"
    end
  end

  @doc false
  def message_for_matcher(matcher_name, [module, method], :refutation) do
    method = inspect method

    case matcher_name do
      :have_received -> "Expected #{module} not to have received #{method}"
    end
  end
  def message_for_matcher(matcher_name, [module, method, args], :refutation) do
    method = inspect method
    args = inspect args

    case matcher_name do
      :have_received -> "Expected #{module} not to have received #{method} with #{args}"
    end
  end

end
