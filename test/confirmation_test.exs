defmodule ConfirmationTest do
  use PhoenixTokenAuth.Case
  use Plug.Test
  import RouterHelper
  alias PhoenixTokenAuth.TestRouter
  alias PhoenixTokenAuth.Registrator
  alias PhoenixTokenAuth.Confirmator
  alias PhoenixTokenAuth.AccountUpdater
  alias PhoenixTokenAuth.TestRepo
  alias PhoenixTokenAuth.User
  import PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.UserHelper


  @email "user@example.com"
  @password "secret"
  @headers [{"content-type", "application/json"}]



  test "confirm user with wrong token" do
    {_, changeset} = Registrator.changeset(%{email: @email, password: @password})
    |> Confirmator.confirmation_needed_changeset
    user = repo.insert!(changeset)

    conn = call(TestRouter, :post, "/api/users/#{user.id}/confirm", %{confirmation_token: "wrong_token"}, @headers)
    assert conn.status == 422
    assert conn.resp_body == "{\"errors\":{\"confirmation_token\":\"invalid\"}}"
  end

  test "confirm a user" do
    {token, changeset} = Registrator.changeset(%{email: @email, password: @password})
    |> Confirmator.confirmation_needed_changeset
    user = repo.insert!(changeset)

    conn = call(TestRouter, :post, "/api/users/#{user.id}/confirm", %{confirmation_token: token}, @headers)
    assert conn.status == 200

    {:ok, token_data} = Poison.decode!(conn.resp_body)
    |> Dict.fetch!("token")
    |> Joken.decode()

    assert token_data.id == user.id

    user = repo.get! UserHelper.model, user.id
    assert user.hashed_confirmation_token == nil
    assert user.confirmed_at != nil
  end

  test "confirm a user's new email" do
    {token, changeset} = Registrator.changeset(%{email: @email, password: @password})
    |> Confirmator.confirmation_needed_changeset
    user = repo.insert!(changeset)
    Confirmator.confirmation_changeset(user, %{"confirmation_token" => token})
    |> TestRepo.update!

    user = TestRepo.one(User)
    {token, changeset} = AccountUpdater.changeset(user, %{"email" => "new@example.com"})
    user = TestRepo.update!(changeset)

    conn = call(TestRouter, :post, "/api/users/#{user.id}/confirm", %{confirmation_token: token}, @headers)
    assert conn.status == 200

    {:ok, token_data} = Poison.decode!(conn.resp_body)
    |> Dict.fetch!("token")
    |> Joken.decode()

    assert token_data.id == user.id

    user = repo.get! UserHelper.model, user.id
    assert user.hashed_confirmation_token == nil
    assert user.unconfirmed_email == nil
    assert user.email == "new@example.com"
  end

end
