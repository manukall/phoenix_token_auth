defmodule PhoenixTokenAuth.Registrator do
  alias Ecto.Changeset
  alias PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.UserHelper

  @doc """
  Returns a changeset setting email and hashed_password on a new user.
  Validates that email and password are present and that email is unique.
  """
  def changeset(params) do

    if params["username"] do
      Changeset.cast(struct(UserHelper.model), params, ~w(username))
      |> Changeset.validate_change(:username, &Util.presence_validator/2)
      |> Changeset.validate_unique(:username, on: Util.repo)
      |> UserHelper.validator
      |> set_hashed_password
      |> Changeset.put_change(:hashed_confirmation_token, nil)
      |> Changeset.put_change(:confirmed_at, Ecto.DateTime.utc)
    else
      Changeset.cast(struct(UserHelper.model), params, ~w(email))
      |> Changeset.validate_change(:email, &Util.presence_validator/2)
      |> Changeset.validate_unique(:email, on: Util.repo)
      |> UserHelper.validator
      |> set_hashed_password
    end
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
