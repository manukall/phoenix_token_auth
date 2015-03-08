defmodule PhoenixTokenAuth.UsersController do
  use Phoenix.Controller
  alias PhoenixTokenAuth.Registrator
  import PhoenixTokenAuth.Util

  plug :action


  def create(conn, %{"user" => params}) do
    changeset = Registrator.changeset(params)
    if changeset.valid? do
      user = repo.insert(changeset)
      json conn, :ok
    else
      send_error(conn, Enum.into(changeset.errors, %{}))
    end
  end
end
