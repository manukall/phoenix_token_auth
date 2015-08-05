defmodule PhoenixTokenAuth do

  defmacro mount do
    quote do
      post  "users",                 PhoenixTokenAuth.Controllers.Users, :create
      post  "users/:id/confirm",     PhoenixTokenAuth.Controllers.Users, :confirm
      post  "sessions",              PhoenixTokenAuth.Controllers.Sessions, :create
      delete  "sessions",            PhoenixTokenAuth.Controllers.Sessions, :delete
      post  "password_resets",       PhoenixTokenAuth.Controllers.PasswordResets, :create
      post  "password_resets/reset", PhoenixTokenAuth.Controllers.PasswordResets, :reset
      get   "account",               PhoenixTokenAuth.Controllers.Account, :show
      put   "account",               PhoenixTokenAuth.Controllers.Account, :update
    end
  end

end
