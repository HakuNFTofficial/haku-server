defmodule HakuServer.Repo.Migrations.CreateNfts do
  use Ecto.Migration

  def change do
    create table(:nfts) do
      add :url, :string
      add :rarity, :integer
      add :owner, :string
      add :metadata, :map
      add :metadata_url, :string

      timestamps()
    end
  end
end
