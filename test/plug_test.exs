defmodule PlugTest do
  use PhoenixTokenAuth.Case
  use Plug.Test
  import RouterHelper
  alias PhoenixTokenAuth.Router
  import PhoenixTokenAuth.Util

  defmodule SecretsController do
    use Phoenix.Controller
    plug :action

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
    {:ok, invalid_token} = Joken.encode(%{id: 123}, "invalid_secret")
    conn = call(Router, :get, "/api/secrets", nil,  [{"authorization", "Bearer #{invalid_token}"}])
    assert conn.status == 401
  end

  test "request a protected resource with valid authentication token" do
    {:ok, valid_token} = Joken.encode(%{id: 123}, token_secret)
    conn = call(Router, :get, "/api/secrets", nil,  [{"authorization", "Bearer #{valid_token}"}])
    assert conn.status == 200
    assert conn.resp_body == "{\"user_id\":123}"
  end


end
