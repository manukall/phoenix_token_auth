defmodule Blacksmith.Config do
  def save(repo, map) do
    repo.insert(map)
  end

  def save_all(repo, list) do
    Enum.map(list, &repo.insert/1)
  end
end

defmodule Forge do
  use Blacksmith

  @save_one_function &Blacksmith.Config.save/2
  @save_all_function &Blacksmith.Config.save_all/2

  register(:user,
           __struct__: PhoenixTokenAuth.User,
           email: Sequence.next(:email, &"user#{&1}@example.com"),
           username: Sequence.next(:username, &"user#{&1}@example.com"),
           hashed_password: PhoenixTokenAuth.Util.crypto_provider.hashpwsalt("secret"),
           confirmed_at: nil
  )

  register(:confirmed_user,
           [prototype: :user],
           confirmed_at: Ecto.DateTime.utc
  )
end
