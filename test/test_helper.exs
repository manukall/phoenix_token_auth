ExUnit.start()

Application.put_env(:phoenix, :filter_parameters, [])
Application.put_env(:phoenix, :format_encoders, [json: Poison])

Code.require_file "test/support/ecto_helper.exs"
Code.require_file "test/support/router_helper.exs"
Code.require_file "test/support/forge.exs"
