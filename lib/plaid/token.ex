defmodule Plaid.Token do
  @moduledoc """
  Functions for working with a Plaid token.

  Through this API you can:

  * Exchange a public token for an access token

  Plaid API Reference: https://plaid.com/docs/quickstart/#-exchange_token-endpoint

  * TODO: incorporate account `_id` in payload.
  """

  alias Plaid.Utilities

  defstruct [:access_token, :item_id, :request_id, :sandbox]

  @endpoint "item/public_token/exchange"

  @create_public_token_endpoint "item/public_token/create"

  @create_stripe_bank_account_token_endpoint "processor/stripe/bank_account_token/create"

  @doc """
  Exchanges a public token for an access token.

  Exchanges a user's public token for an access token. If credentials are not
  supplied, credentials in the default configuration are used.

  Returns access_token or `Plaid.Error` struct.

  Args
  * `params`  - `map` or `string `  - req - public token or Payload
  * `cred`    - `map`               - opt - Plaid credentials

  Payload
  * `public_token` - `string` - req - Public token returned from Plaid Link

  ## Example
  ```
  params = "test,bofa,connected"
  cred = %{client_id: "test_id", secret: "test_secret"}

  {:ok, "test_bofa"} = Plaid.Token.exchange("test,bofa,connected")
  {:ok, "test_bofa"} = Plaid.Token.exchange(params)
  {:ok, "test_bofa"} = Plaid.Token.exchange(params, cred)
  {:error, %Plaid.Error{...}} = Plaid.Token.exchange(params, cred)
  ```
  """
  @spec exchange(binary | map, map) :: {atom, binary | map}
  def exchange(params, cred \\ nil) do
    params =
      cond do
        is_binary(params) ->
          Map.new |> Map.put(:public_token, params)
        true ->
          params
      end

    Plaid.make_request_with_cred(:post, @endpoint, cred || Plaid.config_or_env_cred(), params)
    |> Utilities.handle_plaid_response(:token)
  end

  @spec create_public_token(binary) :: binary
  def create_public_token(access_token, cred \\ nil) do
    params = %{access_token: access_token}
    Plaid.make_request_with_cred(:post, @create_public_token_endpoint, cred || Plaid.config_or_env_cred(), params)
    |> Utilities.handle_plaid_response(:public_token)
  end

  @spec create_stripe_bank_account_token(binary, binary, map) :: {atom, binary | map}
  def create_stripe_bank_account_token(access_token, account_id, cred \\ nil) do
    params = %{access_token: access_token, account_id: account_id}
    Plaid.make_request_with_cred(
      :post,
      @create_stripe_bank_account_token_endpoint,
      cred || Plaid.config_or_env_cred(), params
    )
    |> Utilities.handle_plaid_response(:stripe_bank_account_token)
  end
end
