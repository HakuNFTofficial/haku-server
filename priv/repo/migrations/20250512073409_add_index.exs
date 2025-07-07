defmodule HakuServer.Repo.Migrations.AddIndex do
  use Ecto.Migration

  def change do
    execute(
      "CREATE INDEX index_slices_on_lower_owner_nft_id ON slices (LOWER(owner), nft_id);",
      "DROP INDEX index_slices_on_lower_owner_nft_id;"
    )
  end
end
