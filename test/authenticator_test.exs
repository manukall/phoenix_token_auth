defmodule AuthenticatorTest do
  use PhoenixTokenAuth.Case
  import Mock
  import PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.TestRepo
  alias PhoenixTokenAuth.Authenticator


  @email "user@example.com"
  @password "secret"

  test "authenticate a confirmed user" do
    user = Forge.saved_confirmed_user TestRepo
    {:ok, _token} = Authenticator.authenticate(user.email, "secret")
  end

  test "authenticate an unconfirmed user" do
    user = Forge.saved_user TestRepo
    assert Authenticator.authenticate(user.email, "secret") == {:error, :account_not_confirmed}
  end

  test "authenticate an unknown user" do
    assert Authenticator.authenticate("user@example.com", "secret") == {:error, :unknown_email_or_password}
  end


  test "generate_token_for returns a token with id and exp set" do
    mocked_date = Timex.Date.now
    with_mock Timex.Date, [:passthrough], [now: fn -> mocked_date end] do
      Application.put_env(:phoenix_token_auth, :token_validity_in_minutes, 1)
      user = %{id: 123}
      {:ok, token} = Authenticator.generate_token_for(user)
      {:ok, decoded_token} = Joken.decode(token, token_secret)

      expected_exp = mocked_date
      |> Timex.Date.shift(mins: 1)
      |> Timex.Date.to_secs

      assert decoded_token.id == 123
      assert decoded_token.exp == expected_exp
    end
  end


end
