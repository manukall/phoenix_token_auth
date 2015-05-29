defmodule PosionHelperTest do
  use ExUnit.Case
  alias PhoenixTokenAuth.PoisonHelper

  test "BUGFIX: decode works when the token_id atom does not exist yet" do
    json = PoisonHelper.encode(%{"token_id" => "123"})
    PoisonHelper.decode(json)
  end
end
