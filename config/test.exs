use Mix.Config

config :phoenix_token_auth,
  email_sender: "myapp@example.com",
  welcome_email_subject: fn user -> "Hello #{user.email}" end,
  welcome_email_body: fn user, token -> "the_emails_body" end,
  user_model: PhoenixTokenAuth.User,
  repo: PhoenixTokenAuth.TestRepo

config :phoenix_token_auth, PhoenixTokenAuth.TestRepo,
  adapter: Ecto.Adapters.Postgres,
  url: "ecto://localhost/phoenix_token_auth_test",
  size: 1,
  max_overflow: 0
