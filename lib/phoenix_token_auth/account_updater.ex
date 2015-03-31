defmodule PhoenixTokenAuth.AccountUpdater do
  alias Ecto.Changeset
  alias PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.Confirmator

  @doc """
  Returns confirmation token and changeset updating email and hashed_password on an existing user.
  Validates that email and password are present and that email is unique.
  """
  def changeset(user, params) do
    changeset = Changeset.cast(user, params, ~w())
    |> Util.user_model_validator
    |> apply_password_change
    |> apply_email_change
  end

  def apply_email_change(changeset = %{params: %{"email" => email}}) when email != "" and email != nil do
    {confirmation_token, changeset} = changeset
    |> Changeset.put_change(:unconfirmed_email, email)
    |> Confirmator.confirmation_needed_changeset
  end
  def apply_email_change(changeset), do: {nil, changeset}

  def apply_password_change(changeset = %{params: %{"password" => password}}) when password != "" and password != nil do
    hashed_password = Util.crypto_provider.hashpwsalt(password)
    changeset
    |> Changeset.put_change(:hashed_password, hashed_password)
  end
  def apply_password_change(changeset), do: changeset
end
