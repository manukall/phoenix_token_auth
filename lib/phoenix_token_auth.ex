defmodule PhoenixTokenAuth do

  defmacro mount do
    quote do
      post  "users",                 PhoenixTokenAuth.UsersController, :create
      post  "users/:id/confirm",     PhoenixTokenAuth.UsersController, :confirm
      post  "sessions",              PhoenixTokenAuth.SessionsController, :create
    end
  end

end
