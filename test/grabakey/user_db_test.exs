defmodule Grabakey.PubkeyDbTest do
  use Grabakey.DataCase, async: false

  @email "test@grabakey.org"

  test "insert or update pubkey test" do
    {:ok, pubkey1} = PubkeyDb.create_from_email(@email)
    {:ok, pubkey2} = PubkeyDb.create_from_email(@email)
    [pubkey] = Repo.all(Pubkey)
    assert pubkey.data == pubkey1.data
    assert pubkey.email == pubkey1.email
    assert pubkey.id == pubkey1.id
    assert pubkey.token == pubkey2.token
    assert pubkey.updated_at == pubkey2.updated_at
    assert pubkey1.token != pubkey2.token
    assert pubkey1.updated_at != pubkey2.updated_at
  end

  test "update pubkey pubkey test" do
    {:ok, pubkey1} = PubkeyDb.create_from_email(@email)
    {:ok, pubkey2} = PubkeyDb.update_pubkey(pubkey1, "UPDATED")
    pubkey = PubkeyDb.find_by_email(@email)
    assert pubkey.data == "UPDATED"
    assert pubkey.token == pubkey2.token
    assert pubkey.token != pubkey1.token
  end

  test "find pubkey from email test" do
    {:ok, pubkey} = PubkeyDb.create_from_email(@email)
    assert pubkey == PubkeyDb.find_by_email(@email)
  end

  test "find pubkey from id and token test" do
    {:ok, pubkey} = PubkeyDb.create_from_email(@email)
    assert [pubkey] == Repo.all(Pubkey)
    assert pubkey == PubkeyDb.find_by_id_and_token(pubkey.id, pubkey.token)
    assert nil == PubkeyDb.find_by_id_and_token(pubkey.id, "TOKEN")
  end
end
