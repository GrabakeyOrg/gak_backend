defmodule Grabakey.UserChangesetTest do
  use Grabakey.DataCase, async: false

  @empty %{email: nil, verified: false, pubkey: "EMPTY", token: "EMPTY"}

  test "email must be non blank" do
    changeset = User.changeset(%User{}, %{@empty | email: ""})
    assert %{email: ["can't be blank"]} = errors_on(changeset)
  end

  test "email must have valid format" do
    changeset = User.changeset(%User{}, %{@empty | email: "abc"})
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end

  test "email passes validation" do
    changeset = User.changeset(%User{}, %{@empty | email: "@"})
    assert %{} = errors_on(changeset)
  end
end
