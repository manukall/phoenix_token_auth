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
      conn
      |> put_status(422)
      |> json %{errors: Enum.into(changeset.errors, %{})}
    end
  end
end
