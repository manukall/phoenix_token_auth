[![ProjectTalk](http://www.projecttalk.io/images/gh_badge-3e578a9f437f841de7446bab9a49d103.svg?vsn=d)]
(http://www.projecttalk.io/boards/manukall%2Fphoenix_token_auth?utm_campaign=gh-badge&utm_medium=badge&utm_source=github)

PhoenixTokenAuth
================


Adds token authentication to Phoenix apps using Ecto.

An example app is available at https://github.com/manukall/phoenix_token_auth_react.

## Setup
You need to have a user model with at least the following schema and callback:

```elixir
defmodule MyApp.User do
  use Ecto.Model

  schema "users" do
    field  :email,                       :string     # or :username
    field  :hashed_password,             :string
    field  :hashed_confirmation_token,   :string
    field  :confirmed_at,                Ecto.DateTime
    field  :hashed_password_reset_token, :string
    field  :unconfirmed_email,           :string
    field  :authentication_tokens,       {:array, :string}, default: []
  end

  @required_fields ~w(email)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end
```

Make sure that you have uniqueness constraints on the email or username columns.

Then add PhoenixTokenAuth to your Phoenix router:

```elixir
defmodule MyApp.Router do
  use Phoenix.Router
  require PhoenixTokenAuth

  pipeline :authenticated do
    plug PhoenixTokenAuth.Plug
  end

  scope "/api" do
    pipe_through :api

    PhoenixTokenAuth.mount
  end

  scope "/api" do
    pipe_through :authenticated
    pipe_through :api

    resources "/messages", MessagesController
  end
end
```
This generates routes for sign-up and login and protects the messages resources from unauthenticated access.

The generated routes are:

method | path | description
-------|------|------------
POST | /api/users | sign up
POST | /api/users/:id/confirm | confirm account
POST | /api/session | login, will return a token as JSON
DELETE |  /api/session | logout, invalidated the users current authentication token
POST | /api/password_resets | request a reset-password-email
POST | /api/password_resets/reset | reset a password
GET  | /api/account               | get information about the current user. at the moment this includes only the email address
PUT  | /api/account               | update the current users email or password

If you want to customize the routes, instead of
```
  scope "/api" do
    pipe_through :api

    PhoenixTokenAuth.mount
  end
```
add
```
  scope "/api" do
    pipe_through :api

    post  "users",                 PhoenixTokenAuth.Controllers.Users, :create
    post  "users/:id/confirm",     PhoenixTokenAuth.Controllers.Users, :confirm
    post  "sessions",              PhoenixTokenAuth.Controllers.Sessions, :create
    delete  "sessions",            PhoenixTokenAuth.Controllers.Sessions, :delete
    post  "password_resets",       PhoenixTokenAuth.Controllers.PasswordResets, :create
    post  "password_resets/reset", PhoenixTokenAuth.Controllers.PasswordResets, :reset
    get   "account",               PhoenixTokenAuth.Controllers.Account, :show
    put   "account",               PhoenixTokenAuth.Controllers.Account, :update
  end
```
And customize, change names/pipeline of the routes.


Inside the controller, the authenticated user is accessible inside the connections assigns:

```elixir
def index(conn, _params) do
  user_id = conn.assigns.authenticated_user.id
  ...
end
```

Now add configuration:
```elixir
# config/config.exs
config :phoenix_token_auth,
  user_model: Myapp.User,                                                              # ecto model used for authentication
  repo: Myapp.Repo,                                                                    # ecto repo
  crypto_provider: Comeonin.Bcrypt,                                                    # crypto provider for hashing passwords/tokens. see http://hexdocs.pm/comeonin/
  token_validity_in_minutes: 7 * 24 * 60,                                              # minutes from login until a token expires
  email_sender: "myapp@example.com",                                                   # sender address of emails sent by the app
  emailing_module: MyApp.EmailConstructor,                                             # module implementing the `PhoenixTokenAuth.MailingBehaviour` for generating emails
  mailgun_domain: "example.com",                                                       # domain of your mailgun account
  mailgun_key: "secret",                                                               # secret key of your mailgun account
  user_model_validator: {MyApp.Model, :user_validator}                                 # function receiving and returning the changeset for a user on registration and when updating the account. This is the place to run custom validations.
```

The secret key for signing tokens must be provided for Joken to work. You must
also configure the JSON encoder for Joken to use. For using the Poison Encode function,
we provide the `PhoenixTokenAuth.PoisonHelper`. The secret_key should be set per
environment and should not be committed to the repository.
```elixir
# config/config.exs
config :joken,
  json_module: PhoenixTokenAuth.PoisonHelper,
  algorithm: :HS256 # Optional. defaults to :HS256
```
```elixir
# config/[dev|test|prod].exs
config :joken,
  # Environment specific secret key for signing tokens.
  # This should be a very long random string.
  secret_key: "very secret test key",
```

## Usage

### Signing up / Registering a new user
* POST request to /api/users.
* Body should be JSON encoded `{user: {email: "user@example.com", password: "secret"}}`.
* This will send an email containing the confirmation token.

### Signing up / Registering a new user with username
* POST request to /api/users.
* Body should be JSON encoded `{user: {username: "usernameexample", password: "secret"}}`.
* The user will be registered and, comparing to the email implementation, already confirmed.

### Confirming a user
* POST request to /api/users/:id/confirm
* Body should be JSON encoded `{confirmation_token: "token form the email"}`
* This will mark the user as confirmed and return an authentication token as JSON: `{token: "the_token"}`.

### Logging in
* POST request to /api/sessions
* Body should be JSON encoded `{email: "user@example.com", password: "secret"}`
* Will return an authentication token as JSON: `{token: "the_token"}`

### Logging in with username
* POST request to /api/sessions
* Body should be JSON encoded `{username: "usernameexample", password: "secret"}`
* Will return an authentication token as JSON: `{access_token: "the_token", token_type: "bearer", id: "recordid"}`

### Requesting a protected resource
* Add a header with key `Authorization` and value `Bearer #{token}` to the request.
* `#{token}` is the token from either account confirmation or logging in.

### Logging out
* DELETE request to /api/sessions
* Just stop sending the `Authorization` header.

### Resetting password
* POST request to /api/password_resets
* Body should be JSON encoded `{email: "user@example.com"}`
* This will send an email as configured.
* Once the reset token is received in the email, make a POST request to /api/password_resets/reset with body
`{user_id: 123, password_reset_token: "the_token_from_the_email", password: "the_new_password"}`
* This will change the users password and return an authentication token as JSON: `{token: "the_token"}`.

### Change the current user's password
* PUT request to /api/account
* Body should be JSON encoded `{account: {password: "newpassword"}}`

### Change the current user's email address
* PUT request to /api/account
* Body should be JSON encoded `{account: {email: "new_email@example.com"}}`
* This will send an email containing the confirmation token.
* The change will only be effective after the email address was confirmed.


## TODO:
* Better documentation
* Clean up expired authentication tokens in the db
* Merge the Joken secret_key config into the phoenix_token_auth config.
* Custom work factor config for crypto_provider
* Allow use of scrypt as an alternate crypto_provider
* Example Ecto Phoenix migration, with indexes.
