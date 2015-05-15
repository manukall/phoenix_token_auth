defmodule PhoenixTokenAuth.PasswordResetter do
  alias Ecto.Changeset
  alias PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.Registrator
  alias PhoenixTokenAuth.UserHelper

  @doc """
  Adds the changes needed to create a password reset token.

  Returns {unhashed_password_reset_token, changeset}
  """
  def create_changeset(nil) do
    changeset = Changeset.cast(struct(UserHelper.model), %{}, [])
    |> Changeset.add_error(:email, "not known")
    {nil, changeset}
  end
  def create_changeset(user) do
    {password_reset_token, hashed_password_reset_token} = generate_token

    changeset = user
    |> Changeset.cast(%{}, [])
    |> Changeset.put_change(:hashed_password_reset_token, hashed_password_reset_token)

    {password_reset_token, changeset}
  end

  @doc """
  Changes a users password, if the reset token matches.

  Returns the changeset
  """
  def reset_changeset(nil, _params) do
    changeset = Changeset.cast(struct(UserHelper.model), %{}, [])
    |> Changeset.add_error(:id, :unknown)
    {nil, changeset}
  end
  def reset_changeset(user, params) do
    Changeset.cast(user, params, [])
    |> Changeset.put_change(:hashed_password_reset_token, nil)
    |> Registrator.set_hashed_password
    |> validate_token
  end

  # Generates a random token.
  # Returns {token, hashed_token}.
  defp generate_token do
    token = SecureRandom.urlsafe_base64(64)
    {token, Util.crypto_provider.hashpwsalt(token)}
  end

  defp validate_token(changeset) do
    token_matches = Util.crypto_provider.checkpw(changeset.params["password_reset_token"],
                                            changeset.model.hashed_password_reset_token)
    do_validate_token token_matches, changeset
  end

  defp do_validate_token(true, changeset), do: changeset
  defp do_validate_token(false, changeset) do
    Changeset.add_error changeset, :password_reset_token, :invalid
  end
end
