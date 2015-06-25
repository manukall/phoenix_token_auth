use Mix.Config

config :phoenix_token_auth,
  email_sender: "myapp@example.com",
  emailing_module: PhoenixTokenAuth.TestMailing,
  user_model: PhoenixTokenAuth.User,
  repo: PhoenixTokenAuth.TestRepo

config :phoenix_token_auth, PhoenixTokenAuth.TestRepo,
  adapter: Ecto.Adapters.Postgres,
  url: "ecto://localhost/phoenix_token_auth_test",
  size: 1,
  max_overflow: 0

config :logger, level: :warn

# Setting configuration for the Joken library
config :joken,
  secret_key: "very secret test key"
