PhoenixTokenAuth
================

Adds token authentication to Phoenix apps using Ecto.

## Usage

```elixir
defmodule MyApp.Router do
  use Phoenix.Router

  scope "/api", SttBackend do
    pipe_through :api

    PhoenixTokenAuth.mount
  end
end
```
this generates:
method | path | description
---------------------------
POST | /api/users | sign up
POST | /api/session | login, will return a token as JSON



## Restrict routes to authenticated users
```elixir
defmodule MyApp.Router do
  use Phoenix.Router

  pipeline :authenticated_api do
    plug PhoenixTokenAuth.Plug
  end

  scope "/api" do
    resources: messages, MessagesController
  end

end
```

This adds resource routes for messages that are only accessible to authenticated users.
Inside the controller methods, conn.assigns.authenticated_user_id holds the id of the authenticated user.


## Configuration

```elixir
# config/config.exs
config :phoenix_token_auth,
  user_model: MyApp.User, # Ecto model used for authentication
  repo: MyApp.Repo, # Ecto repo
  crypto_provider Comeonin.Bcrypt # Crypto provider for hashing passwords/tokens. See http://hexdocs.pm/comeonin/
```
