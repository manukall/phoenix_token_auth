defmodule LoginTest do
  use PhoenixTokenAuth.Case
  use Plug.Test
  import RouterHelper
  alias PhoenixTokenAuth.TestRouter
  alias PhoenixTokenAuth.Registrator
  alias PhoenixTokenAuth.Confirmator
  alias PhoenixTokenAuth.UserHelper
  import PhoenixTokenAuth.Util


  @email "user@example.com"
  @username "user@example.com"
  @password "secret"
  @headers [{"content-type", "application/json"}]

  test "sign in with unknown email" do
    conn = call(TestRouter, :post, "/api/sessions", %{password: @password, email: @email}, @headers)
    assert conn.status == 401
    assert conn.resp_body == Poison.encode!(%{errors: %{base: "Unknown email or password"}})
  end

  test "sign in with wrong password" do
    Registrator.changeset(%{email: @email, password: @password})
    |> repo.insert!

    conn = call(TestRouter, :post, "/api/sessions", %{password: "wrong", email: @email}, @headers)
    assert conn.status == 401
    assert conn.resp_body == Poison.encode!(%{errors: %{base: "Unknown email or password"}})
  end

  test "sign in as unconfirmed user" do
    {_, changeset} = Registrator.changeset(%{"email" => @email, "password" => @password})
    |> Confirmator.confirmation_needed_changeset
    repo.insert!(changeset)

    conn = call(TestRouter, :post, "/api/sessions", %{password: @password, email: @email}, @headers)
    assert conn.status == 401
    assert conn.resp_body == Poison.encode!(%{errors: %{base: "Account not confirmed yet. Please follow the instructions we sent you by email."}})
  end

  test "sign in as confirmed user" do
    Registrator.changeset(%{"email" => @email, "password" => @password})
    |> Ecto.Changeset.put_change(:confirmed_at, Ecto.DateTime.utc)
    |> repo.insert!

    conn = call(TestRouter, :post, "/api/sessions", %{password: @password, email: @email}, @headers)
    assert conn.status == 200
    %{"token" => token} = Poison.decode!(conn.resp_body)

    assert repo.one(UserHelper.model).authentication_tokens == [token]
  end

  test "sign in with unknown username" do
    conn = call(TestRouter, :post, "/api/sessions", %{password: @password, username: @username}, @headers)
    assert conn.status == 401
    assert conn.resp_body == Poison.encode!(%{errors: %{base: "Unknown email or password"}})
  end

  test "sign in with username and wrong password" do
    Registrator.changeset(%{"username" => @username, "password" => @password})
    |> repo.insert!

    conn = call(TestRouter, :post, "/api/sessions", %{password: "wrong", username: @username}, @headers)
    assert conn.status == 401
    assert conn.resp_body == Poison.encode!(%{errors: %{base: "Unknown email or password"}})
  end

  test "sign in user with username" do
    Registrator.changeset(%{"username" => @username, "password" => @password})
    |> repo.insert!

    conn = call(TestRouter, :post, "/api/sessions", %{password: @password, username: @username}, @headers)
    assert conn.status == 200
    %{"access_token" => token, "token_type" => "bearer"} = Poison.decode!(conn.resp_body)

    assert repo.one(UserHelper.model).authentication_tokens == [token]
  end

end
