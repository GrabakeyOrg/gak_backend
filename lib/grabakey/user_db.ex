defmodule Grabakey.UserDb do
  alias Grabakey.Repo
  alias Grabakey.User

  def create_from_email(email) do
    token = Ecto.ULID.generate()

    %User{}
    |> User.changeset(%{email: email, token: token, pubkey: "PUBKEY"})
    |> Repo.insert()
  end

  def find_by_id(id) do
    Repo.get_by(User, id: id)
  end

  def find_by_email(email) do
    Repo.get_by(User, email: email)
  end
end
