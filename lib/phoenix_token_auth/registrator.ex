defmodule PhoenixTokenAuth.Registrator do
  alias Ecto.Changeset
  alias PhoenixTokenAuth.Util

  @doc """
  Returns a changeset setting email and hashed_password on a new user.
  Validates that email and password are present and that email is unique.
  """
  def changeset(params) do
    changeset = Changeset.cast(struct(Util.user_model), params, ~w(email))
    |> Changeset.validate_change(:email, &Util.presence_validator/2)
    |> Changeset.validate_unique(:email, on: Util.repo)
    |> Util.user_model_validator
    |> set_hashed_password
  end


  def set_hashed_password(changeset = %{errors: [_]}), do: changeset
  def set_hashed_password(changeset = %{params: %{"password" => password}}) when password != "" and password != nil do
    hashed_password = Util.crypto_provider.hashpwsalt(password)

    changeset
    |> Changeset.put_change(:hashed_password, hashed_password)
  end
  def set_hashed_password(changeset) do
    changeset
    |> Changeset.add_error(:password, "can't be blank")
  end

end
