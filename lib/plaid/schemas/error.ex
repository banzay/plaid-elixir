defmodule Plaid.Error do
  @moduledoc false
  defstruct [:error_type, :error_code, :error_message, :display_message]
end
