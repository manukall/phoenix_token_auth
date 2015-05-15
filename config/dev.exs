use Mix.Config

config :phoenix_token_auth,
  email_sender: "myapp@example.com"

# Setting configuration for the Joken library
config :joken,
  secret_key: "very secret key"
