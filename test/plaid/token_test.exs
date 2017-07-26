defmodule Plaid.TokenTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
    cred = %{client_id: "test_id", secret: "test_secret"}
    bad_cred = %{client_id: "foo", secret: "bar"}
    {:ok, cred: cred, bad_cred: bad_cred}
  end

  @tag exchange: true
  test "Exchange token with success, string params, no credentials" do
    use_cassette "token_test/token" do
      {:ok, %{access_token: access_token, item_id: item_id, request_id: request_id}} = Plaid.Token.exchange("test,bofa,connected")
      assert access_token == "test_bofa"
      assert item_id == "item_id"
      assert request_id == "request_id"
    end
  end

  @tag exchange: true
  test "Exchange token with error, string params, no credentials" do
    use_cassette "token_test/error" do
      assert {:error, _} = Plaid.Token.exchange("badvalue")
    end
  end

  @tag exchange: true
  test "Exchange token with success, string params, credentials", %{cred: cred} do
    use_cassette "token_test/cred" do
      {:ok, %{access_token: access_token, item_id: item_id, request_id: request_id}} = Plaid.Token.exchange("test,bofa,connected", cred)
      assert access_token == "test_bofa"
      assert item_id == "item_id"
      assert request_id == "request_id"
    end
  end

  @tag exchange: true
  test "Exchange token with error, string params, credentials", %{bad_cred: bad_cred} do
    use_cassette "token_test/bad_cred" do
      assert {:error, _} = Plaid.Token.exchange("test,bofa,connected", bad_cred)
    end
  end
end
