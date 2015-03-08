defmodule PhoenixTokenAuth.Authenticator do
  import PhoenixTokenAuth.Util
  import Ecto.Query, only: [from: 2]
  alias Timex.Date

  def authenticate(email, password) do
    query = from u in user_model, where: u.email == ^email
    user = repo.one query
    case check_password(user, password) do
      {:ok, user} -> generate_token_for(user)
      error -> error
    end
  end

  @unknown_password_error_message :unknown_email_or_password
  defp check_password(nil, _) do
    crypto_provider.dummy_checkpw
    {:error, @unknown_password_error_message}
  end
  defp check_password(user, password) do
    if crypto_provider.checkpw(password, user.hashed_password) do
      {:ok, user}
    else
      {:error, @unknown_password_error_message}
    end
  end

  def generate_token_for(user) do
    Map.take(user, [:id])
    |> Map.merge(%{exp: seconds_till_exp})
    |> Joken.encode(token_secret)
  end

  defp seconds_till_exp do
    Date.now
    |> Date.shift(mins: token_validity_minutes)
    |> Date.to_secs
  end

  defp token_secret do
    Application.get_env(:phoenix_token_auth, :token_secret)
  end

  defp token_validity_minutes do
    Application.get_env(:phoenix_token_auth, :token_validity_in_minutes, 7 * 24 * 60)
  end
end
