defmodule HakuServer.Repo.Migrations.AddLists do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :nft_id, :integer

      add :seller, :string
      add :list_price, :integer
      add :signature, :string
      add :expired_at, :utc_datetime
      add :listed_at, :utc_datetime

      add :status, :string, default: "pending"

      add :buyer, :string
      add :filled_at, :utc_datetime
      add :tx_hash, :string

      timestamps()
    end
  end
end
