ExUnit.start()

Application.put_env(:phoenix, :filter_parameters, [])
Application.put_env(:phoenix, :format_encoders, [json: Poison])

Application.put_env(:phoenix_token_auth, :token_secret, "this_should_be_very_secret")

Code.require_file "test/support/ecto_helper.exs"
Code.require_file "test/support/router_helper.exs"
Code.require_file "test/support/forge.exs"
