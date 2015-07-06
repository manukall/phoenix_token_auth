defmodule PlugTest do
  use PhoenixTokenAuth.Case
  use Plug.Test
  import RouterHelper
  alias PhoenixTokenAuth.Router
  alias PhoenixTokenAuth.TestRepo
  alias PhoenixTokenAuth.User
  alias PhoenixTokenAuth.Authenticator

  defmodule SecretsController do
    use Phoenix.Controller

    def index(conn, _params) do
      json conn, %{user_id: conn.assigns.authenticated_user.id}
    end
  end

  defmodule Router do
    use Phoenix.Router

    pipeline :authenticated do
      plug :accepts, ~w(json)
      plug PhoenixTokenAuth.Plug
    end

    scope "/api" do
      pipe_through :authenticated

      get "/secrets", SecretsController, :index
    end
  end


  test "request a protected resource without authentication token" do
    conn = call(Router, :get, "/api/secrets", %{})
    assert conn.status == 401
  end

  test "request a protected resource with invalid authentication token" do
    # {:ok, invalid_token} = Joken.encode(%{id: 123}) # , "invalid_secret")
    json_module = Application.get_env(:joken, :json_module)
    algorithm   = Application.get_env(:joken, :algorithm, :HS256)
    claims      = %{}
    {:ok, invalid_token} = Joken.Token.encode("invalid_secret",
      json_module, %{id: 123}, algorithm, claims)
    conn = call(Router, :get, "/api/secrets", nil,  [{"authorization", "Bearer #{invalid_token}"}])
    assert conn.status == 401
  end

  test "request a protected resource with valid but unknown authentication token" do
    {:ok, valid_token} = Joken.encode(%{id: 123})
    conn = call(Router, :get, "/api/secrets", nil,  [{"authorization", "Bearer #{valid_token}"}])
    assert conn.status == 401
  end

  test "request a protected resource with valid and known authentication token" do
    user = Forge.saved_user TestRepo
    valid_token = Authenticator.generate_token_for(user)
    Authenticator.generate_token_for(TestRepo.get!(User, user.id))
    Authenticator.generate_token_for(TestRepo.get!(User, user.id))

    conn = call(Router, :get, "/api/secrets", nil,  [{"authorization", "Bearer #{valid_token}"}])
    assert conn.status == 200
    assert conn.resp_body == "{\"user_id\":#{user.id}}"
  end


end
