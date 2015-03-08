defmodule PhoenixTokenAuth do
  alias Phoenix.Router

  defmacro mount do
    quote do
      post  "users",     PhoenixTokenAuth.UsersController, :create
      post  "sessions",  PhoenixTokenAuth.SessionsController, :create
    end
  end

end
