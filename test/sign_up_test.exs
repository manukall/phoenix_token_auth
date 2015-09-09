defmodule SignUpTest do
  use PhoenixTokenAuth.Case
  use Plug.Test
  import Mock

  import RouterHelper
  alias PhoenixTokenAuth.TestRouter
  alias PhoenixTokenAuth.TestRepo
  alias PhoenixTokenAuth.User


  @email "user@example.com"
  @password "secret"
  @headers [{"content-type", "application/json"}, {"language", "en"}]

  setup do
    on_exit fn ->
      Application.delete_env :phoenix_token_auth, :user_model_validator
    end
  end

  test "sign up" do
    with_mock Mailgun.Client, [send_email: fn _, _ -> {:ok, "response"} end] do
      conn = call(TestRouter, :post, "/api/users", %{user: %{password: @password, email: @email}}, @headers)
      assert conn.status == 200
      assert conn.resp_body == Poison.encode!("ok")

      # fields are set in the db
      user = TestRepo.one User
      assert user.email == @email
      # hashed token is set
      assert !is_nil(user.hashed_confirmation_token)

      mail = :meck.capture(:first, Mailgun.Client, :send_email, :_, 2)

      assert Keyword.fetch!(mail, :to) == @email
      assert Keyword.fetch!(mail, :subject) == "Hello " <> @email
      assert Keyword.fetch!(mail, :from) == "myapp@example.com"
      assert Keyword.fetch!(mail, :text) == "the_emails_body with language en"
    end
  end

  test "sign up with missing email" do
    conn = call(TestRouter, :post, "/api/users", %{"user" => %{"password" => @password}}, @headers)
    assert conn.status == 422

    errors = Poison.decode!(conn.resp_body)
    |> Dict.fetch!("errors")

    assert errors["email"] == "can't be blank"
  end

  test "sign up with missing password" do
    conn = call(TestRouter, :post, "/api/users", %{user: %{email: @email}}, @headers)
    assert conn.status == 422

    errors = Poison.decode!(conn.resp_body)
    |> Dict.fetch!("errors")

    assert errors["password"] == "can't be blank"
  end

  test "sign up with custom validations" do
    Application.put_env(:phoenix_token_auth, :user_model_validator, fn changeset ->
      Ecto.Changeset.add_error(changeset, :password, :too_short)
    end)
    conn = call(TestRouter, :post, "/api/users", %{user: %{email: @email, password: @password}}, @headers)
    assert conn.status == 422

    errors = Poison.decode!(conn.resp_body)
    |> Dict.fetch!("errors")

    assert errors["password"] == "too_short"
  end
end
