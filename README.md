PhoenixTokenAuth
================

Adds token authentication to Phoenix apps using Ecto.

## Usage

```elixir
defmodule MyApp.Router do
  use Phoenix.Router

  pipeline :authenticated do
    plug PhoenixTokenAuth.Plug
  end

  scope "/api", SttBackend do
    pipe_through :api

    PhoenixTokenAuth.mount
  end

  scope "/api" do
    pipe_through :authenticated
    pipe_through :api

    resources: messages, MessagesController
  end
end
```
This generates routes for sign-up and login and protects the messages resources from unauthenticated access.

The generated routes are:

method | path | description
---------------------------
POST | /api/users | sign up
POST | /api/session | login, will return a token as JSON

Inside the controller, the authenticates user's id is accessible inside the connections assigns:

```elixir
def index(conn, _params) do
  user_id = conn.assigns.authenticated_user.id
  ...
end
```

## Configuration

```elixir
# config/config.exs
config :phoenix_token_auth,
  user_model: MyApp.User, # Ecto model used for authentication
  repo: MyApp.Repo, # Ecto repo
  crypto_provider: Comeonin.Bcrypt, # Crypto provider for hashing passwords/tokens. See http://hexdocs.pm/comeonin/
  token_secret: "the_very_secret_token", # Secret string used to sign the authentication token
  token_validity_in_minutes: 7 * 24 * 60 # Minutes from login until a token expires
```


## TODO:
* Better documentation
* Email confirmation of accounts
* Password resetting
