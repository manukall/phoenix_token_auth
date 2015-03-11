defmodule ConfirmationTest do
  use PhoenixTokenAuth.Case
  use Plug.Test
  import RouterHelper
  alias PhoenixTokenAuth.TestRouter
  alias PhoenixTokenAuth.Registrator
  alias PhoenixTokenAuth.Confirmator
  import PhoenixTokenAuth.Util


  @email "user@example.com"
  @password "secret"
  @headers [{"Content-Type", "application/json"}]



  test "confirm user with wrong token" do
    {_, changeset} = Registrator.changeset(%{email: @email, password: @password})
    |> Confirmator.sign_up_changeset
    user = repo.insert changeset

    conn = call(TestRouter, :post, "/api/users/#{user.id}/confirm", %{confirmation_token: "wrong_token"}, @headers)
    assert conn.status == 422
    assert conn.resp_body == "{\"errors\":{\"confirmation_token\":\"invalid\"}}"
  end

  test "confirm a user" do
    {token, changeset} = Registrator.changeset(%{email: @email, password: @password})
    |> Confirmator.sign_up_changeset
    user = repo.insert changeset

    conn = call(TestRouter, :post, "/api/users/#{user.id}/confirm", %{confirmation_token: token}, @headers)
    assert conn.status == 200

    {:ok, token_data} = Poison.decode!(conn.resp_body)
    |> Dict.fetch!("token")
    |> Joken.decode(token_secret)

    assert token_data.id == user.id

    user = repo.get! user_model, user.id
    assert user.hashed_confirmation_token == nil
    assert user.confirmed_at != nil
  end

end
