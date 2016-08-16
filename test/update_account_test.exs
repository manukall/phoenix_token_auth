defmodule UpdateAccountTest do
  use PhoenixTokenAuth.Case
  use Plug.Test
  import Mock

  import RouterHelper
  alias PhoenixTokenAuth.TestRouter
  alias PhoenixTokenAuth.TestRepo
  alias PhoenixTokenAuth.User
  alias PhoenixTokenAuth.Authenticator
  alias PhoenixTokenAuth.Util


  @old_email "old@example.com"
  @new_email "user@example.com"
  @old_password "old_secret"
  @new_password "secret"
  @headers [{"content-type", "application/json"}]
  setup do
    user = TestRepo.insert!(%User{email: @old_email,
                                 confirmed_at: Ecto.DateTime.utc,
                                 hashed_password: Util.crypto_provider.hashpwsalt(@old_password)})
    token = Authenticator.generate_token_for(user)
    headers = [{"authorization", "Bearer " <> token} | @headers]

    on_exit fn ->
      Application.delete_env :phoenix_token_auth, :user_model_validator
    end

    {:ok, %{user: user, headers: headers}}
  end

  test "update password", context do
    with_mock Mailgun.Client, [send_email: fn _, _ -> {:ok, "response"} end] do
      conn = call(TestRouter, :put, "/api/account", %{account: %{password: @new_password}}, context.headers)
      assert conn.status == 200
      assert conn.resp_body == Poison.encode!("ok")
      {:ok, _} = Authenticator.authenticate_by_email(@old_email, @new_password)

      assert :meck.num_calls(Mailgun.Client, :send_email, :_, 2) == 0
    end
  end

  test "update email", context do
    with_mock Mailgun.Client, [send_email: fn _, _ -> {:ok, "response"} end] do
      conn = call(TestRouter, :put, "/api/account", %{account: %{email: @new_email}}, context.headers)
      assert conn.status == 200
      assert conn.resp_body == Poison.encode!("ok")
      {:ok, _} = Authenticator.authenticate_by_email(@old_email, @old_password)
      assert TestRepo.one(User).unconfirmed_email == @new_email

      mail = :meck.capture(:first, Mailgun.Client, :send_email, :_, 2)
      assert Keyword.fetch!(mail, :to) == @new_email
      assert Keyword.fetch!(mail, :subject) == "Please confirm your email address"
      assert Keyword.fetch!(mail, :from) == "myapp@example.com"
      assert Util.crypto_provider.checkpw(Keyword.fetch!(mail, :text), TestRepo.one(User).hashed_confirmation_token)
    end
  end

  test "set email to the same email it was before", context do
    with_mock Mailgun.Client, [send_email: fn _, _ -> {:ok, "response"} end] do
      conn = call(TestRouter, :put, "/api/account", %{account: %{email: @old_email}}, context.headers)
      assert conn.status == 200
      assert conn.resp_body == Poison.encode!("ok")
      {:ok, _} = Authenticator.authenticate_by_email(@old_email, @old_password)
      assert TestRepo.one(User).unconfirmed_email == nil

      assert :meck.num_calls(Mailgun.Client, :send_email, :_, 2) == 0
    end
  end

  test "update account with custom validations", context do
    with_mock Mailgun.Client, [send_email: fn _, _ -> {:ok, "response"} end] do
      Application.put_env(:phoenix_token_auth, :user_model_validator, fn changeset ->
        Ecto.Changeset.add_error(changeset, :password, :too_short)
      end)
      conn = call(TestRouter, :put, "/api/account", %{account: %{password: @new_password}}, context.headers)
      assert conn.status == 422
      assert conn.resp_body == Poison.encode!(%{errors: %{password: :too_short}})
      {:ok, _} = Authenticator.authenticate_by_email(@old_email, @old_password)
      assert :meck.num_calls(Mailgun.Client, :send_email, :_, 2) == 0
    end
  end

end
