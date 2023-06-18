defmodule Grabakey.UserCrudTest do
  use Grabakey.DataCase, async: false

  @empty %{email: nil, data: "PUBKEY", token: "TOKEN"}

  test "user crud test" do
    user = User.changeset(%User{}, %{@empty | email: "test@grabakey.org"})
    assert {:ok, %User{} = user} = Repo.insert(user)
    assert 26 == String.length(user.id)
    assert user.email == "test@grabakey.org"
    assert user.data == "PUBKEY"
    assert user.token == "TOKEN"
    assert [%User{} = user] = Repo.all(User)
    assert 26 == String.length(user.id)
    assert user.email == "test@grabakey.org"
    assert user.data == "PUBKEY"
    assert user.token == "TOKEN"
    assert user = Repo.get(User, user.id)
    assert 26 == String.length(user.id)
    assert user.email == "test@grabakey.org"
    assert user.data == "PUBKEY"
    assert user.token == "TOKEN"
    assert user = Repo.get_by(User, id: user.id)
    assert 26 == String.length(user.id)
    assert user.email == "test@grabakey.org"
    assert user.data == "PUBKEY"
    assert user.token == "TOKEN"
    assert user = Repo.get_by(User, email: user.email)
    assert 26 == String.length(user.id)
    assert user.data == "PUBKEY"
    assert user.token == "TOKEN"
  end

  test "user unique test" do
    changeset = User.changeset(%User{}, %{@empty | email: "test@grabakey.org"})
    assert {:ok, %User{} = user} = Repo.insert(changeset)
    assert 26 == String.length(user.id)
    assert user.email == "test@grabakey.org"
    assert user.data == "PUBKEY"
    assert user.token == "TOKEN"
    changeset = User.changeset(user, %{})
    assert {:error, %Ecto.Changeset{} = result} = Repo.insert(changeset)

    assert result.errors == [
             email:
               {"has already been taken",
                [constraint: :unique, constraint_name: "users_email_index"]}
           ]
  end

  test "user delete test" do
    changeset = User.changeset(%User{}, %{@empty | email: "test@grabakey.org"})
    assert {:ok, %User{} = user} = Repo.insert(changeset)
    assert 26 == String.length(user.id)
    assert user.email == "test@grabakey.org"
    assert user.data == "PUBKEY"
    assert user.token == "TOKEN"
    Repo.delete_all(User)
    assert [] = Repo.all(User)
  end
end
