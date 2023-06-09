defmodule Grabakey.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "users" do
    field(:email, :string)
    field(:pubkey, :string)
    field(:token, :string)
    field(:verified, :boolean, default: false)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :pubkey, :token, :verified])
    |> validate_required([:email, :pubkey, :token, :verified])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
