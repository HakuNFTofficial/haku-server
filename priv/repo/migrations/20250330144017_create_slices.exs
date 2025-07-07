defmodule HakuServer.Repo.Migrations.CreateSlices do
  use Ecto.Migration

  def change do
    create table(:slices) do
      add :nft_id, references(:nfts, on_delete: :delete_all), null: false
      add :x, :integer, null: false
      add :y, :integer, null: false
      add :owner, :string
      add :locked, :boolean, default: false

      timestamps()
    end

    # create unique index for each nft's each coordinate position
    create unique_index(:slices, [:nft_id, :x, :y])
    # create index for search performance
    create index(:slices, [:nft_id])
    create index(:slices, [:owner])
    create index(:slices, [:locked])
  end
end
