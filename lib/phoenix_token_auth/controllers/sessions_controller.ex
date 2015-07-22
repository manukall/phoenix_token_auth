defmodule PhoenixTokenAuth.Controllers.Sessions do
  use Phoenix.Controller
  alias PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.Authenticator

  plug PhoenixTokenAuth.Plug when action in [:delete]


  @doc """
  Log in as an existing user.

  Parameter are "email" and "password".

  Responds with status 200 and {token: token} if credentials were correct.
  Responds with status 401 and {errors: error_message} otherwise.
  """
  def create(conn, %{"username" => username, "password" => password}) do
    case Authenticator.authenticate_by_username(username, password) do
      {:ok, user} -> json conn, %{access_token: Authenticator.generate_token_for(user), token_type: "bearer", id: user.id}
      {:error, errors} -> Util.send_error(conn, errors, 401)
    end
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Authenticator.authenticate_by_email(email, password) do
      {:ok, user} -> json conn, %{token: Authenticator.generate_token_for(user)}
      {:error, errors} -> Util.send_error(conn, errors, 401)
    end
  end

  @doc """
  Destroy the active session.
  Will delete the authentication token from the user table.

  Responds with status 200 if no error occured.
  """
  def delete(conn, _params) do
    {:ok, token} = conn
    |> Util.token_from_conn
    tokens_left_after_delete = conn.assigns.authenticated_user.authentication_tokens
    |> List.delete(token)
    Util.repo.update!(%{conn.assigns.authenticated_user | authentication_tokens: tokens_left_after_delete})
    json conn, :ok
  end
end
