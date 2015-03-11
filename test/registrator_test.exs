defmodule RegistratorTest do
  use PhoenixTokenAuth.Case
  import PhoenixTokenAuth.Util
  alias PhoenixTokenAuth.Registrator


  test "changeset validates presence of email" do
    changeset = Registrator.changeset(%{})
    assert changeset.errors[:email] == :required

    changeset = Registrator.changeset(%{"email" => ""})
    assert changeset.errors[:email] == :required

    changeset = Registrator.changeset(%{"email" => nil})
    assert changeset.errors[:email] == :required
  end

  test "changeset validates presence of password" do
    changeset = Registrator.changeset(%{})
    assert changeset.errors[:password] == :required

    changeset = Registrator.changeset(%{"password" => ""})
    assert changeset.errors[:password] == :required

    changeset = Registrator.changeset(%{"password" => nil})
    assert changeset.errors[:password] == :required
  end

  test "changeset validates uniqueness of email" do
    user = Forge.saved_user PhoenixTokenAuth.TestRepo
    changeset = Registrator.changeset(%{"email" => user.email})

    assert changeset.errors[:email] == :unique
  end

  test "changeset includes the hashed password" do
    changeset = Registrator.changeset(%{"password" => "secret"})

    hashed_pw = Ecto.Changeset.get_change(changeset, :hashed_password)
    assert crypto_provider.checkpw("secret", hashed_pw)
  end

  test "changeset is valid with email and password" do
    changeset = Registrator.changeset(%{"password" => "secret", "email" => "unique@example.com"})

    assert changeset.valid?
  end

end
