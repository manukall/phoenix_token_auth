defmodule ResetPasswordTest do
  import Mock
  use PhoenixTokenAuth.Case
  use Plug.Test
  import RouterHelper
  alias PhoenixTokenAuth.TestRouter
  alias PhoenixTokenAuth.Registrator
  alias PhoenixTokenAuth.PasswordResetter
  import PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.UserHelper


  @email "user@example.com"
  @headers [{"content-type", "application/json"}]

  test "request a reset token for an unknown email" do
    conn = call(TestRouter, :post, "/api/password_resets", %{email: @email}, @headers)
    assert conn.status == 422
    assert conn.resp_body == Poison.encode!(%{errors: %{email: "not known"}})
  end

  test "request a reset token" do
    with_mock Mailgun.Client, [send_email: fn _, _ -> {:ok, "response"} end] do
      Registrator.changeset(%{"email" => @email, "password" => "oldpassword"})
      |> Ecto.Changeset.put_change(:confirmed_at, Ecto.DateTime.utc)
      |> repo.insert!

      conn = call(TestRouter, :post, "/api/password_resets", %{email: @email}, @headers)

      assert conn.status == 200
      assert Poison.decode!(conn.resp_body) == "ok"

      user = repo.one UserHelper.model
      assert user.hashed_password_reset_token != nil
    end
  end

  test "reset password with a wrong token" do
    {_reset_token, changeset} = Registrator.changeset(%{email: @email, password: "oldpassword"})
    |> PasswordResetter.create_changeset
    user = repo.insert!(changeset)

    params = %{user_id: user.id, password_reset_token: "wrong_token", password: "newpassword"}
    conn = call(TestRouter, :post, "/api/password_resets/reset", params, @headers)
    assert conn.status == 422
    assert conn.resp_body == Poison.encode!(%{errors: %{password_reset_token: :invalid}})
  end

  test "reset password" do
    {reset_token, changeset} = Registrator.changeset(%{email: @email, password: "oldpassword"})
    |> PasswordResetter.create_changeset
    user = repo.insert!(changeset)

    params = %{user_id: user.id, password_reset_token: reset_token, password: "newpassword"}
    conn = call(TestRouter, :post, "/api/password_resets/reset", params, @headers)
    assert conn.status == 200

    {:ok, token_data} = Poison.decode!(conn.resp_body)
    |> Dict.fetch!("token")
    |> Joken.decode()

    assert token_data.id == user.id
  end

end
