defmodule PhoenixTokenAuth.Plug do
  import Plug.Conn
  alias PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.UserHelper

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
    case check_token(Util.token_from_conn(conn)) do
      {:ok, data} -> assign(conn, :authenticated_user, data)
      {:error, message} -> send_resp(conn, 401, Poison.encode!(%{error: message})) |> halt
    end
  end

  defp check_token({:ok, token}) do
    Joken.decode(token)
    |> check_whether_token_is_known(token)
  end
  defp check_token(_), do: {:error, "Not authorized"}

  defp check_whether_token_is_known({:ok, token_data}, token) do
    import Ecto.Query, only: [from: 2]
    query = from u in UserHelper.model,
     where: u.id == ^token_data.id and
       fragment("? @> ?", u.authentication_tokens, ^[token])

    case Util.repo.one(query) do
      nil -> {:error, :unknown_token}
      user -> {:ok, user}
    end
  end
  defp check_whether_token_is_known({:error, message}, _), do: {:error, message}

end
