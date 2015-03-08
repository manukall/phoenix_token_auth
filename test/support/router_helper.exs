defmodule PhoenixTokenAuth.TestRouter do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ~w(json)
  end

  scope "/api" do
    pipe_through :api

    require PhoenixTokenAuth
    PhoenixTokenAuth.mount
  end
end

defmodule RouterHelper do
  import Plug.Test

  def call(router, verb, path, params \\ nil, headers \\ []) do
    router.call(conn(verb, path, params, headers), [])
  end
end
