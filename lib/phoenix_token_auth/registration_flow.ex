defmodule PhoenixTokenAuth.RegistrationFlow do
  alias PhoenixTokenAuth.Mailer
  alias PhoenixTokenAuth.Util

  def user_created_by_username?(changeset) do
    if changeset.valid? do
      Util.repo.transaction(fn ->
        case Util.repo.insert(changeset) do
          {:ok, _} -> true
          {:error, _} -> false
        end
      end)
    end
  end

  def user_created_and_emailed?(changeset, confirmation_token, conn) do
    if changeset.valid? do
      Util.repo.transaction(fn ->
        case Util.repo.insert(changeset) do
          {:ok, user} ->
            Mailer.send_welcome_email(user, confirmation_token, conn)
          {:error, _} ->
            false
        end
      end)
    end
  end
end
