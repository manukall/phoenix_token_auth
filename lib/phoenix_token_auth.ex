defmodule PhoenixTokenAuth do

  defmacro mount do
    quote do
      post  "users",                 PhoenixTokenAuth.UsersController, :create
      post  "users/:id/confirm",     PhoenixTokenAuth.UsersController, :confirm
      post  "sessions",              PhoenixTokenAuth.SessionsController, :create
      post  "password_resets",       PhoenixTokenAuth.PasswordResetsController, :create
      post  "password_resets/reset", PhoenixTokenAuth.PasswordResetsController, :reset
    end
  end

end
