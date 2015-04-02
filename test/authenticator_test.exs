defmodule AuthenticatorTest do
  use PhoenixTokenAuth.Case
  import Mock
  import PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.TestRepo
  alias PhoenixTokenAuth.Authenticator
  alias PhoenixTokenAuth.User


  @email "user@example.com"
  @password "secret"

  test "authenticate a confirmed user" do
    user = Forge.saved_confirmed_user TestRepo
    {:ok, token} = Authenticator.authenticate(user.email, "secret")
    user = TestRepo.get User, user.id
    assert user.authentication_tokens == [token]
  end

  test "authenticate an unconfirmed user" do
    user = Forge.saved_user TestRepo
    assert Authenticator.authenticate(user.email, "secret") == {:error, %{base: "Account not confirmed yet. Please follow the instructions we sent you by email."}}
  end

  test "authenticate an unknown user" do
    assert Authenticator.authenticate("user@example.com", "secret") == {:error, %{base: "Unknown email or password"}}
  end


  test "generate_token_for returns a token with id and exp set" do
    mocked_date = Timex.Date.now
    with_mock Timex.Date, [:passthrough], [now: fn -> mocked_date end] do
      Application.put_env(:phoenix_token_auth, :token_validity_in_minutes, 1)
      user = Forge.saved_user TestRepo, %{id: 123}
      token = Authenticator.generate_token_for(user)
      {:ok, decoded_token} = Joken.decode(token, token_secret)

      expected_exp = mocked_date
      |> Timex.Date.shift(mins: 1)
      |> Timex.Date.to_secs

      assert decoded_token.id == 123
      assert decoded_token.exp == expected_exp
    end
  end


end
