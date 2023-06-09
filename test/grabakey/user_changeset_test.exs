defmodule Grabakey.UserChangesetTest do
  use Grabakey.DataCase, async: false

  @empty %{email: nil, verified: false, pubkey: "EMPTY", token: "EMPTY"}

  test "email must be non blank" do
    changeset = User.changeset(%User{}, %{@empty | email: ""})
    assert %{email: ["can't be blank"]} = errors_on(changeset)
  end

  test "email without @ is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "abc"})
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end

  test "email with \s is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a c@"})
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end

  test "email with \n is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a\nc@"})
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end

  test "email with \r is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a\rc@"})
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end

  test "email with \t is rejected" do
    changeset = User.changeset(%User{}, %{@empty | email: "a\tc@"})
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end

  test "email passes validation" do
    changeset = User.changeset(%User{}, %{@empty | email: "@"})
    assert %{} = errors_on(changeset)
  end
end
