defmodule PhoenixTokenAuth.Util do
  import Plug.Conn
  import Phoenix.Controller
  import Ecto.Query, only: [from: 2]

  def user_model do
    Application.get_env(:phoenix_token_auth, :user_model)
  end

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

  def token_secret do
    Application.get_env(:phoenix_token_auth, :token_secret)
  end

  def find_user_by_email(email) do
    query = from u in user_model, where: u.email == ^email
    repo.one query
  end
end
