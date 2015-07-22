defmodule PhoenixTokenAuth.Authenticator do
  alias PhoenixTokenAuth.Util
  alias Timex.Date
  alias PhoenixTokenAuth.UserHelper

  @doc """
Tries to authenticate a user with the given email and password.

Returns:
* {:ok, token} if a confirmed user is found. The token has to be send in the "authorization" header on following requests: "Authorization: Bearer \#{token}"
* {:error, message} if the user was not confirmed before or no matching user was found
"""
  @unconfirmed_account_error_message "Account not confirmed yet. Please follow the instructions we sent you by email."
  def authenticate_by_email(email, password) do
    user = UserHelper.find_by_email(email)
    authenticate(user, password)
  end
  def authenticate_by_username(username, password) do
    user = UserHelper.find_by_username(username)
    authenticate(user, password)
  end

  def authenticate(user, password) do
    case check_password(user, password) do
      {:ok, %{confirmed_at: nil}} -> {:error, %{base: @unconfirmed_account_error_message}}
      {:ok, _} -> {:ok, user}
      error -> error
    end
  end

  @unknown_password_error_message "Unknown email or password"
  defp check_password(nil, _) do
    Util.crypto_provider.dummy_checkpw
    {:error, %{base: @unknown_password_error_message}}
  end
  defp check_password(user, password) do
    if Util.crypto_provider.checkpw(password, user.hashed_password) do
      {:ok, user}
    else
      {:error, %{base: @unknown_password_error_message}}
    end
  end

  @doc """
  Returns {:ok, token}, where "token" is an authentication token for the user.
  This token encapsulates the users id and is valid for the number of minutes configured in
  ":phoenix_token_auth, :token_validity_in_minutes"
  """
  def generate_token_for(user) do
    token = generate_unique_token_for(user)
    UserHelper.persist_token(user, token)
    token
  end
  defp generate_unique_token_for(user) do
    {:ok, token} = Map.take(user, [:id])
    |> Map.merge(%{exp: token_expiry_secs})
    |> Map.merge(%{token_id: SecureRandom.base64(24)})
    |> Joken.encode()
    if Enum.member?(user.authentication_tokens, token) do
      generate_unique_token_for(user)
    else
      token
    end
  end

  defp token_expiry_secs do
    Date.now
    |> Date.shift(mins: token_validity_minutes)
    |> Date.to_secs
  end

  defp token_validity_minutes do
    Application.get_env(:phoenix_token_auth, :token_validity_in_minutes, 7 * 24 * 60)
  end
end
