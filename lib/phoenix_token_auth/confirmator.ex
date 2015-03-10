defmodule PhoenixTokenAuth.Confirmator do
  alias Ecto.Changeset
  import PhoenixTokenAuth.Util

  def sign_up_changeset(changeset) do
    {confirmation_token, hashed_confirmation_token} = generate_token

    changeset = changeset
    |> Changeset.put_change(:hashed_confirmation_token, hashed_confirmation_token)

    {confirmation_token, changeset}
  end

  defp generate_token do
    token = SecureRandom.urlsafe_base64(64)
    {token, crypto_provider.hashpwsalt(token)}
  end

  def confirmation_changeset(user, params) do
    Changeset.cast(user, params, [])
    |> Changeset.put_change(:hashed_confirmation_token, nil)
    |> Changeset.put_change(:confirmed_at, Ecto.DateTime.utc)
    |> validate_token
  end

  defp validate_token(changeset) do
    token_matches = crypto_provider.checkpw(changeset.params["confirmation_token"],
                                            changeset.model.hashed_confirmation_token)
    do_validate_token token_matches, changeset
  end

  defp do_validate_token(true, changeset), do: changeset
  defp do_validate_token(false, changeset) do
    Changeset.add_error changeset, :confirmation_token, :invalid
  end

end
