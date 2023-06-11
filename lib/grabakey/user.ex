defmodule Grabakey.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "users" do
    field(:email, :string)
    field(:pubkey, :string)
    field(:token, :string)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :pubkey, :token])
    |> validate_required([:email, :pubkey, :token])
    |> validate_format(:email, ~r/^\S+@\S+(\.\S+)+$/)
    |> unique_constraint(:email)
  end
end
