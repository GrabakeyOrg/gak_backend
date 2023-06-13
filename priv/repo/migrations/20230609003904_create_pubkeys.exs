defmodule Grabakey.Repo.Migrations.CreatePubkeys do
  use Ecto.Migration

  def change do
    create table(:pubkeys, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:email, :string)
      add(:data, :string)
      add(:token, :string)

      timestamps()
    end

    create(unique_index(:pubkeys, [:email]))
  end
end
