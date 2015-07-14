defmodule PhoenixTokenAuth.Controllers.Users do
  use Phoenix.Controller
  alias PhoenixTokenAuth.Registrator
  alias PhoenixTokenAuth.Confirmator
  alias PhoenixTokenAuth.Authenticator
  alias PhoenixTokenAuth.Mailer
  alias PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.UserHelper

  plug :action


  @doc """
  Sign up as a new user.

  Params should be:
      {user: {email: "user@example.com", password: "secret"}}

  If successfull, sends a welcome email.

  Responds with status 200 and body "ok" if successfull.
  Responds with status 422 and body {errors: {field: "message"}} otherwise.
  """
  def create(conn, %{"user" => params}) do
    if params["username"] do
      changeset = Registrator.changeset(params)
    else
      {confirmation_token, changeset} = Registrator.changeset(params)
      |> Confirmator.confirmation_needed_changeset
    end

    if changeset.valid? do
      case Util.repo.transaction fn ->
        user = Util.repo.insert(changeset)
        Mailer.send_welcome_email(user, confirmation_token)
      end do
        {:ok, _} -> json conn, :ok
      end
    else
      Util.send_error(conn, Enum.into(changeset.errors, %{}))
    end
  end

  @doc """
  Confirm either a new user or an existing user's new email address.

  Parameter "id" should be the user's id.
  Parameter "confirmation" should be the user's confirmation token.

  If the confirmation matches, the user will be confirmed and signed in.

  Responds with status 200 and body {token: token} if successfull. Use this token in subsequent requests as authentication.
  Responds with status 422 and body {errors: {field: "message"}} otherwise.
  """
  def confirm(conn, params = %{"id" => user_id, "confirmation_token" => _}) do
    user = Util.repo.get! UserHelper.model, user_id
    changeset = Confirmator.confirmation_changeset user, params

    if changeset.valid? do
        Util.repo.update(changeset)
        token = Authenticator.generate_token_for(user)
        json conn, %{token: token}
    else
      Util.send_error(conn, Enum.into(changeset.errors, %{}))
    end
  end
end
