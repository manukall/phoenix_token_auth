#https://github.com/elixir-lang/ecto/blob/master/integration_test/pg/test_helper.exs

# Basic test repo
alias PhoenixTokenAuth.TestRepo
Application.put_env(:phoenix_token_auth, TestRepo,
                    adapter: Ecto.Adapters.Postgres,
                    url: "ecto://localhost/phoenix_token_auth_test",
                    size: 1,
                    max_overflow: 0)

defmodule PhoenixTokenAuth.TestRepo do
  use Ecto.Repo, otp_app: :phoenix_token_auth
end

defmodule PhoenixTokenAuth.Case do
  use ExUnit.CaseTemplate
  setup_all do
    Ecto.Adapters.SQL.begin_test_transaction(TestRepo, [])
    on_exit fn -> Ecto.Adapters.SQL.rollback_test_transaction(TestRepo, []) end
    :ok
  end
  setup do
    Ecto.Adapters.SQL.restart_test_transaction(TestRepo, [])
    :ok
  end
end

defmodule UsersMigration do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email,    :text
      add :username, :text
      add :hashed_password, :text
    end

    create index(:users, [:email], unique: true)
  end
end

# Load up the repository, start it, and run migrations
:ok = Ecto.Storage.down(TestRepo)
:ok = Ecto.Storage.up(TestRepo)
{:ok, _pid} = TestRepo.start_link
:ok = Ecto.Migrator.up(TestRepo, 0, UsersMigration, log: false)

defmodule PhoenixTokenAuth.User do
  use Ecto.Model

  schema "users" do
    field  :email,                       :string
    field  :hashed_password,             :string
  end
end

Application.put_env(:phoenix_token_auth, :user_model, PhoenixTokenAuth.User)
Application.put_env(:phoenix_token_auth, :repo, PhoenixTokenAuth.TestRepo)
