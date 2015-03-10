defmodule PhoenixTokenAuth.Plug do
  import Plug.Conn
  import PhoenixTokenAuth.Util

  @behaviour Plug

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
