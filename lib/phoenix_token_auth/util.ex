defmodule PhoenixTokenAuth.Util do

  def user_model do
    Application.get_env(:phoenix_token_auth, :user_model)
  end

  def repo do
    Application.get_env(:phoenix_token_auth, :repo)
  end

  def crypto_provider do
    Application.get_env(:phoenix_token_auth, :crypto_provider, Comeonin.Bcrypt)
  end
end
