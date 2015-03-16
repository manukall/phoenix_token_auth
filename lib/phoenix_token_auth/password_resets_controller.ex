defmodule PhoenixTokenAuth.PasswordResetsController do
  use Phoenix.Controller
  alias PhoenixTokenAuth.PasswordResetter
  alias PhoenixTokenAuth.Mailer
  alias PhoenixTokenAuth.Authenticator
  import PhoenixTokenAuth.Util

  plug :action


  @doc """
  Create a password reset token for a user

  Params should be:
      {email: "user@example.com"}

  If successfull, sends an email with instructions on how to reset the password.

  Responds with status 200 and body "ok" if successfull.
  Responds with status 422 and body {errors: [messages]} otherwise.
  """
  def create(conn, %{"email" => email}) do
    user = find_user_by_email(email)
    {password_reset_token, changeset} = PasswordResetter.create_changeset(user)

    if changeset.valid? do
      case repo.transaction fn ->
        user = repo.update(changeset)
        Mailer.send_password_reset_email(user, password_reset_token)
      end do
        {:ok, _} -> json conn, :ok
      end
    else
      send_error(conn, Enum.into(changeset.errors, %{}))
    end
  end

  @doc """
  Resets a users password if the provided token matches

  Params should be:
      {user_id: 1, password_reset_token: "abc123"}

  Responds with status 200 and body {token: token} if successfull. Use this token in subsequent requests as authentication.
  Responds with status 422 and body {errors: [messages]} otherwise.
  """
  def reset(conn, params = %{"user_id" => user_id}) do
    user = repo.get user_model, user_id
    changeset = PasswordResetter.reset_changeset(user, params)

    if changeset.valid? do
      user = repo.update(changeset)
      {:ok, token} = Authenticator.generate_token_for(user)
      json conn, %{token: token}
    else
      send_error(conn, Enum.into(changeset.errors, %{}))
    end
  end

end
