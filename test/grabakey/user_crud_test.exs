defmodule Grabakey.PubkeyCrudTest do
  use Grabakey.DataCase, async: false

  @empty %{email: nil, data: "PUBKEY", token: "TOKEN"}

  test "pubkey crud test" do
    pubkey = Pubkey.changeset(%Pubkey{}, %{@empty | email: "test@grabakey.org"})
    assert {:ok, %Pubkey{} = pubkey} = Repo.insert(pubkey)
    assert 26 == String.length(pubkey.id)
    assert pubkey.email == "test@grabakey.org"
    assert pubkey.data == "PUBKEY"
    assert pubkey.token == "TOKEN"
    assert [%Pubkey{} = pubkey] = Repo.all(Pubkey)
    assert 26 == String.length(pubkey.id)
    assert pubkey.email == "test@grabakey.org"
    assert pubkey.data == "PUBKEY"
    assert pubkey.token == "TOKEN"
    assert pubkey = Repo.get(Pubkey, pubkey.id)
    assert 26 == String.length(pubkey.id)
    assert pubkey.email == "test@grabakey.org"
    assert pubkey.data == "PUBKEY"
    assert pubkey.token == "TOKEN"
    assert pubkey = Repo.get_by(Pubkey, id: pubkey.id)
    assert 26 == String.length(pubkey.id)
    assert pubkey.email == "test@grabakey.org"
    assert pubkey.data == "PUBKEY"
    assert pubkey.token == "TOKEN"
    assert pubkey = Repo.get_by(Pubkey, email: pubkey.email)
    assert 26 == String.length(pubkey.id)
    assert pubkey.data == "PUBKEY"
    assert pubkey.token == "TOKEN"
  end

  test "pubkey unique test" do
    changeset = Pubkey.changeset(%Pubkey{}, %{@empty | email: "test@grabakey.org"})
    assert {:ok, %Pubkey{} = pubkey} = Repo.insert(changeset)
    assert 26 == String.length(pubkey.id)
    assert pubkey.email == "test@grabakey.org"
    assert pubkey.data == "PUBKEY"
    assert pubkey.token == "TOKEN"
    changeset = Pubkey.changeset(pubkey, %{})
    assert {:error, %Ecto.Changeset{} = result} = Repo.insert(changeset)

    assert result.errors == [
             email:
               {"has already been taken",
                [constraint: :unique, constraint_name: "pubkeys_email_index"]}
           ]
  end

  test "pubkey delete test" do
    changeset = Pubkey.changeset(%Pubkey{}, %{@empty | email: "test@grabakey.org"})
    assert {:ok, %Pubkey{} = pubkey} = Repo.insert(changeset)
    assert 26 == String.length(pubkey.id)
    assert pubkey.email == "test@grabakey.org"
    assert pubkey.data == "PUBKEY"
    assert pubkey.token == "TOKEN"
    Repo.delete_all(Pubkey)
    assert [] = Repo.all(Pubkey)
  end
end
