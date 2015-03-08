defmodule RouterTest do
  use ExUnit.Case
  use Plug.Test
  import RouterHelper
  alias PhoenixTokenAuth.TestRouter


  @email "user@example.com"
  @password "secret"
  @headers %{"Content-Type" => "application/json"}

  test "sign up" do
    conn = call(TestRouter, :post, "/api/users", %{user: %{password: @password, email: @email}}, @headers)
    assert conn.status == 200
    assert conn.resp_body == Poison.encode!("ok")
  end

  test "sign up with missing email" do
    conn = call(TestRouter, :post, "/api/users", %{user: %{password: @password}}, @headers)
    assert conn.status == 422

    errors = Poison.decode!(conn.resp_body)
    |> Dict.fetch!("errors")

    assert errors["email"] == "required"
  end

  test "sign up with missing password" do
    conn = call(TestRouter, :post, "/api/users", %{user: %{email: @email}}, @headers)
    assert conn.status == 422

    errors = Poison.decode!(conn.resp_body)
    |> Dict.fetch!("errors")

    assert errors["password"] == "required"
  end
end
