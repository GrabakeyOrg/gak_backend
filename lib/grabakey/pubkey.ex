defmodule Grabakey.Pubkey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "pubkeys" do
    field(:email, :string)
    field(:data, :string)
    field(:token, :string)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(pubkey, attrs) do
    pubkey
    |> cast(attrs, [:email, :data, :token])
    |> validate_required([:email, :data, :token])
    |> validate_format(
      :email,
      ~r/^[-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*@([-_a-zA-Z0-9]+\.)+[a-zA-Z]+$/
    )
    |> unique_constraint(:email)
  end
end
