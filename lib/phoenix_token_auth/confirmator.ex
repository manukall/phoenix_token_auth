defmodule PhoenixTokenAuth.Confirmator do
  alias Ecto.Changeset
  alias PhoenixTokenAuth.Util

  @doc """
  Adds the changes needed for a user's email confirmation to the given changeset.

  Returns {unhashed_confirmation_token, changeset}
  """
  def confirmation_needed_changeset(changeset) do
    {confirmation_token, hashed_confirmation_token} = generate_token

    changeset = changeset
    |> Changeset.put_change(:hashed_confirmation_token, hashed_confirmation_token)

    {confirmation_token, changeset}
  end

  # Generates a random token.
  # Returns {token, hashed_token}.
  defp generate_token do
    token = SecureRandom.urlsafe_base64(64)
    {token, Util.crypto_provider.hashpwsalt(token)}
  end

  @doc """
  Returns a changeset which, when applied, confirms the user.
  If params["confirmation_token"] does not match, an error is added
  to the changeset.
  """
  def confirmation_changeset(user = %{confirmed_at: nil}, params) do
    Changeset.cast(user, params, [])
    |> Changeset.put_change(:hashed_confirmation_token, nil)
    |> Changeset.put_change(:confirmed_at, Ecto.DateTime.utc)
    |> validate_token
  end
  def confirmation_changeset(user = %{unconfirmed_email: unconfirmed_email}, params) when unconfirmed_email != nil do
    Changeset.cast(user, params, [])
    |> Changeset.put_change(:hashed_confirmation_token, nil)
    |> Changeset.put_change(:unconfirmed_email, nil)
    |> Changeset.put_change(:email, unconfirmed_email)
    |> validate_token
  end

  defp validate_token(changeset) do
    token_matches = Util.crypto_provider.checkpw(changeset.params["confirmation_token"],
                                            changeset.model.hashed_confirmation_token)
    do_validate_token token_matches, changeset
  end

  defp do_validate_token(true, changeset), do: changeset
  defp do_validate_token(false, changeset) do
    Changeset.add_error changeset, :confirmation_token, :invalid
  end

end
