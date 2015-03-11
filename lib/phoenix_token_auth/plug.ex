defmodule PhoenixTokenAuth.Plug do
  import Plug.Conn
  import PhoenixTokenAuth.Util

  @behaviour Plug

  @moduledoc """
  Plug that protects routes from unauthenticated access.
  If a header with name "authorization" and value "Bearer \#{token}"
  is present, and "token" can be decoded with the applications token secret,
  the user is authenticated and the decoded token is assigned to the connection
  under the key "authenticated_user".
  """

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case check_token(get_req_header(conn, "authorization")) do
      {:ok, data} -> assign(conn, :authenticated_user, data)
      {:error, message} -> send_resp(conn, 401, Poison.encode!(%{error: message})) |> halt
    end
  end

  defp check_token(["Bearer " <> token]) do
    Joken.decode(token, token_secret)
  end
  defp check_token(_), do: {:error, "Not authorized"}

end
