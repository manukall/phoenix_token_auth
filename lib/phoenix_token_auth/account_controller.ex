defmodule PhoenixTokenAuth.AccountController do
  use Phoenix.Controller
  alias PhoenixTokenAuth.Mailer
  alias PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.UserHelper
  alias PhoenixTokenAuth.AccountUpdater

  plug PhoenixTokenAuth.Plug
  plug :action


  @doc """
  Get the account data for the current user. Currently this only returns the email address.

  Responds with status 200 and body {account: {email: "user@example.com"}}.
  """
  def show(conn, _params) do
    user = conn
    |> current_user
    json conn, %{account: %{email: user.email}}
  end

  @doc """
  Update email address and password of the current user.
  If the email address should be updated, the user will receive an email to his new address.
  The stored email address will only be updated after clicking the link in that message.

  Responds with status 200 and body "ok" if successfull.
  """
  def update(conn, %{"account" => params}) do
    {confirmation_token, changeset} = conn
    |> current_user
    |> AccountUpdater.changeset(params)
    if changeset.valid? do
      case Util.repo.transaction fn ->
        user = Util.repo.update(changeset)
        if (confirmation_token != nil) do
          Mailer.send_new_email_address_email(user, confirmation_token)
        end
      end do
        {:ok, _} -> json conn, :ok
      end
    else
      Util.send_error(conn, Enum.into(changeset.errors, %{}))
    end
  end

  defp current_user(conn) do
    Util.repo.get(UserHelper.model, conn.assigns.authenticated_user.id)
  end

end
