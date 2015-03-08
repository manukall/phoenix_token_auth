defmodule PhoenixTokenAuth.SessionsController do
  use Phoenix.Controller
  import PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.Authenticator

  plug :action


  def create(conn, %{"email" => email, "password" => password}) do
    case Authenticator.authenticate(email, password) do
      {:ok, token} -> json conn, %{token: token}
      {:error, message} -> send_error(conn, message, 401)
    end
  end
end
