defmodule Grabakey.UserDbTest do
  use Grabakey.DataCase, async: false

  @email "test@grabakey.org"

  test "insert or update user test" do
    {:ok, user1} = UserDb.create_from_email(@email)
    {:ok, user2} = UserDb.create_from_email(@email)
    [user] = Repo.all(User)
    assert user.pubkey == user1.pubkey
    assert user.email == user1.email
    assert user.id == user1.id
    assert user.token == user2.token
    assert user.updated_at == user2.updated_at
    assert user1.token != user2.token
    assert user1.updated_at != user2.updated_at
  end

  test "update user pubkey test" do
    {:ok, user1} = UserDb.create_from_email(@email)
    {:ok, user2} = UserDb.update_pubkey(user1, "UPDATED")
    user = UserDb.find_by_email(@email)
    assert user.pubkey == "UPDATED"
    assert user.token == user2.token
    assert user.token != user1.token
  end

  test "find user from email test" do
    {:ok, user} = UserDb.create_from_email(@email)
    assert user == UserDb.find_by_email(@email)
  end

  test "find user from id and token test" do
    {:ok, user} = UserDb.create_from_email(@email)
    assert [user] == Repo.all(User)
    assert user == UserDb.find_by_id_and_token(user.id, user.token)
    assert nil == UserDb.find_by_id_and_token(user.id, "TOKEN")
  end
end
