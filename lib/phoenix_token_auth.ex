defmodule PhoenixTokenAuth do
  alias Phoenix.Router

  defmacro mount do
    quote do
      post  "users",     PhoenixTokenAuth.UsersController, :create
    end
  end

end
