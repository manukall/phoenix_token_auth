defmodule PhoenixTokenAuth.TestRouter do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ~w(json)
  end

  pipeline :authenticated do
    plug PhoenixTokenAuth.Plug
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
    conn = conn(verb, path, params, headers: headers) |> Plug.Conn.fetch_params
    router.call(conn, router.init([]))
  end
end
