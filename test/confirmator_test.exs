defmodule ConfirmatorTest do
  use PhoenixTokenAuth.Case
  import Mock
  import PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.Confirmator


  test "confirmation_needed_changeset adds the hashed token" do
    {token, changeset} = %Ecto.Changeset{}
      |> Ecto.Changeset.cast(:empty, [], [])
      |> Confirmator.confirmation_needed_changeset()
    hashed_confirmation_token = Ecto.Changeset.get_change(changeset, :hashed_confirmation_token)

    assert crypto_provider.checkpw(token, hashed_confirmation_token)
  end

  test "confirmation_changeset adds an error if the token does not match" do
    {_token, user} = Forge.user(hashed_confirmation_token: "123secret")
    |> Ecto.Changeset.cast(:empty, [])
    |> Confirmator.confirmation_needed_changeset
    user = Ecto.Changeset.apply_changes(user)

    changeset = Confirmator.confirmation_changeset(user, %{"confirmation_token" => "wrong"})

    assert !changeset.valid?
    assert changeset.errors[:confirmation_token] == :invalid
  end

  test "confirmation_changeset clears the saved token and sets confirmed at if the token matches" do
    mocked_date = Ecto.DateTime.utc
    with_mock Ecto.DateTime, [:passthrough], [utc: fn -> mocked_date end] do
      {token, user} = Forge.user(hashed_confirmation_token: "123secret")
      |> Ecto.Changeset.cast(:empty, [])
      |> Confirmator.confirmation_needed_changeset
      user = Ecto.Changeset.apply_changes(user)

      changeset = Confirmator.confirmation_changeset(user, %{"confirmation_token" => token})

      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :hashed_confirmation_token, :not_here) == nil
      assert Ecto.Changeset.get_change(changeset, :confirmed_at) == mocked_date
    end
  end

end
