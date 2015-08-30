defmodule PhoenixTokenAuth.Controllers.Users do
  use Phoenix.Controller
  alias PhoenixTokenAuth.Registrator
  alias PhoenixTokenAuth.Confirmator
  alias PhoenixTokenAuth.RegistrationFlow
  alias PhoenixTokenAuth.Authenticator
  alias PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.UserHelper


  @doc """
  Sign up as a new user.

  Params should be:
      {user: {email: "user@example.com", password: "secret"}}

  To be considered valid, a record must pass both validations *and* constraints.
  Validations can be run before querying the db, but we have to insert/update the
  record to determine if all constraints have been fulfilled.

  If successful, sends a welcome email.

  Responds with status 200 and body "ok" if successful.
  Responds with status 422 and body {errors: {field: "message"}} otherwise.
  """
  def create(conn, params = %{"user" => %{"email" => email}}) when email != "" and email != nil do
    {confirmation_token, changeset} = Registrator.changeset(params["user"])
    |> Confirmator.confirmation_needed_changeset

    if changeset |> RegistrationFlow.user_created_and_emailed?(confirmation_token, conn) do
      conn |> json :ok
    else
      conn |> respond_with_errors(changeset.errors)
    end
  end

  def create(conn, params = %{"user" => %{"username" => username}}) when username != "" and username != nil do
    changeset = Registrator.changeset(params["user"])

    if changeset |> RegistrationFlow.user_created_by_username? do
      conn |> json :ok
    else
      conn |> respond_with_errors(changeset.errors)
    end
  end

  def create(conn, params) do
    changeset = Registrator.changeset(params["user"])
    conn |> respond_with_errors(changeset.errors)
  end

  @doc """
  Confirm either a new user or an existing user's new email address.

  Parameter "id" should be the user's id.
  Parameter "confirmation" should be the user's confirmation token.

  If the confirmation matches, the user will be confirmed and signed in.

  Responds with status 200 and body {token: token} if successful. Use this token in subsequent requests as authentication.
  Responds with status 422 and body {errors: {field: "message"}} otherwise.
  """
  def confirm(conn, params = %{"id" => user_id, "confirmation_token" => _}) do
    user = Util.repo.get! UserHelper.model, user_id
    changeset = Confirmator.confirmation_changeset user, params

    if changeset.valid? do
        Util.repo.update!(changeset)
        token = Authenticator.generate_token_for(user)
        json conn, %{token: token}
    else
      conn |> respond_with_errors(changeset.errors)
    end
  end

  defp respond_with_errors(conn, errors) do
    Util.send_error(conn, Enum.into(errors, %{}))
  end
end
