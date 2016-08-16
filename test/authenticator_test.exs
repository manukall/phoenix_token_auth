defmodule AuthenticatorTest do
  use PhoenixTokenAuth.Case
  import Mock
  alias PhoenixTokenAuth.TestRepo
  alias PhoenixTokenAuth.Authenticator
  alias PhoenixTokenAuth.User


  @email "user@example.com"
  @password "secret"

  test "authenticate a confirmed user" do
    user = Forge.saved_confirmed_user TestRepo
    {:ok, _} = Authenticator.authenticate_by_email(user.email, "secret")
  end

  test "authenticate an unconfirmed user" do
    user = Forge.saved_user TestRepo
    assert Authenticator.authenticate_by_email(user.email, "secret") == {:error, %{base: "Account not confirmed yet. Please follow the instructions we sent you by email."}}
  end

  test "authenticate an unknown user" do
    assert Authenticator.authenticate_by_email("user@example.com", "secret") == {:error, %{base: "Unknown email or password"}}
  end


  test "generate_token_for returns a token with id and exp set" do
    mocked_date = Timex.Date.now
    with_mock Timex.Date, [:passthrough], [now: fn -> mocked_date end] do
      Application.put_env(:phoenix_token_auth, :token_validity_in_minutes, 1)
      user = Forge.saved_user TestRepo, %{id: 123}
      token = Authenticator.generate_token_for(user)
      {:ok, decoded_token} = Joken.decode(token)

      expected_exp = mocked_date
      |> Timex.Date.shift(mins: 1)
      |> Timex.Date.to_secs

      assert decoded_token.id == 123
      assert decoded_token.exp == expected_exp
      assert TestRepo.get(User, user.id).authentication_tokens == [token]
    end
  end

  test "generate_token_for returns a token with id, interpreter role and exp set" do
    mocked_date = Timex.Date.now
    with_mock Timex.Date, [:passthrough], [now: fn -> mocked_date end] do
      Application.put_env(:phoenix_token_auth, :token_validity_in_minutes, 1)
      user = Forge.saved_user TestRepo, %{id: 123, role: "interpreter"}
      token = Authenticator.generate_token_for(user)
      {:ok, decoded_token} = Joken.decode(token)

      expected_exp = mocked_date
      |> Timex.Date.shift(mins: 1)
      |> Timex.Date.to_secs

      assert decoded_token.id == 123
      assert decoded_token.role == "interpreter"
      assert decoded_token.exp == expected_exp
      assert TestRepo.get(User, user.id).authentication_tokens == [token]
    end
  end

  test "generate_token_for returns a token with id, customer role and exp set" do
    mocked_date = Timex.Date.now
    with_mock Timex.Date, [:passthrough], [now: fn -> mocked_date end] do
      Application.put_env(:phoenix_token_auth, :token_validity_in_minutes, 1)
      user = Forge.saved_user TestRepo, %{id: 123, role: "customer"}
      token = Authenticator.generate_token_for(user)
      {:ok, decoded_token} = Joken.decode(token)

      expected_exp = mocked_date
      |> Timex.Date.shift(mins: 1)
      |> Timex.Date.to_secs

      assert decoded_token.id == 123
      assert decoded_token.role == "customer"
      assert decoded_token.exp == expected_exp
      assert TestRepo.get(User, user.id).authentication_tokens == [token]
    end
  end

  test "generate_token_for returns a token with id, admin role and exp set" do
    mocked_date = Timex.Date.now
    with_mock Timex.Date, [:passthrough], [now: fn -> mocked_date end] do
      Application.put_env(:phoenix_token_auth, :token_validity_in_minutes, 1)
      user = Forge.saved_user TestRepo, %{id: 123, role: "admin"}
      token = Authenticator.generate_token_for(user)
      {:ok, decoded_token} = Joken.decode(token)

      expected_exp = mocked_date
      |> Timex.Date.shift(mins: 1)
      |> Timex.Date.to_secs

      assert decoded_token.id == 123
      assert decoded_token.role == "admin"
      assert decoded_token.exp == expected_exp
      assert TestRepo.get(User, user.id).authentication_tokens == [token]
    end
  end

  test "generate_token_for adds a new, different token, if one already exists" do
    Forge.saved_user TestRepo
    token_1  = Authenticator.generate_token_for(TestRepo.one(User))
    token_2  = Authenticator.generate_token_for(TestRepo.one(User))
    assert TestRepo.one(User).authentication_tokens == [token_2, token_1]
  end


end
