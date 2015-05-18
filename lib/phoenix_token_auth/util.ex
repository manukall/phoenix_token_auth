defmodule PhoenixTokenAuth.Util do
  import Plug.Conn
  import Phoenix.Controller

  def repo do
    Application.get_env(:phoenix_token_auth, :repo)
  end

  def crypto_provider do
    Application.get_env(:phoenix_token_auth, :crypto_provider, Comeonin.Bcrypt)
  end

  def send_error(conn, error, status \\ 422) do
    conn
    |> put_status(status)
    |> json %{errors: error}
  end

  def presence_validator(field, nil), do: [{field, "can't be blank"}]
  def presence_validator(field, ""), do: [{field, "can't be blank"}]
  def presence_validator(_field, _), do: []

  def token_from_conn(conn) do
    Plug.Conn.get_req_header(conn, "authorization")
    |> token_from_header
  end
  defp token_from_header(["Bearer " <> token]), do: {:ok, token}
  defp token_from_header(_), do: {:error, :not_present}

end
