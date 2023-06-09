defmodule Grabakey.UserDbTest do
  use Grabakey.DataCase, async: false

  @email "test@grabakey.org"

  test "user insert or update test" do
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
    # IO.inspect({user, user1, user2})
    # IO.inspect({user.updated_at, user1.updated_at, user2.updated_at})
  end
end
