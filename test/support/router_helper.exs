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
  use Plug.Test

  def call(router, verb, path, params \\ nil, headers \\ []) do
    conn = conn(verb, path, params)
    conn = Enum.reduce(headers, conn, fn ({name, value}, conn) ->
      put_req_header(conn, name, value)
    end)
    conn = Plug.Conn.fetch_query_params(conn)
    router.call(conn, router.init([]))
  end
end
