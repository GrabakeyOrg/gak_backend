defmodule Grabakey.PubkeyDb do
  alias Grabakey.Repo
  alias Grabakey.Pubkey
  import Ecto.Query

  @data "ssh-ed25519 PUBKEY nobody@localhost"

  def create_from_email(email) do
    token = Ecto.ULID.generate()

    %Pubkey{}
    |> Pubkey.changeset(%{email: email, token: token, data: @data})
    |> Repo.insert(conflict_target: :email, on_conflict: {:replace, [:token, :updated_at]})
  end

  def update_pubkey(pubkey, data) do
    token = Ecto.ULID.generate()

    pubkey
    |> Pubkey.changeset(%{token: token, data: data})
    |> Repo.update()
  end

  def find_by_id(id) do
    Repo.get_by(Pubkey, id: id)
  end

  def find_by_email(email) do
    Repo.get_by(Pubkey, email: email)
  end

  def find_by_id_and_token_5m(id, token) do
    updated =
      DateTime.utc_now()
      |> DateTime.add(-5, :minute)
      |> DateTime.to_naive()

    from(pk in Pubkey,
      where: pk.id == ^id and pk.token == ^token and pk.updated_at > ^updated
    )
    |> Repo.one()
  end

  def delete(pubkey) do
    Repo.delete(pubkey)
  end
end
