defmodule GeniusMonad.Repo.Migrations.AddOffers do
  use Ecto.Migration

  def change do
    # status: pending, seller_accept, seller_reject, buyer_cancel, completed, expired

    create table(:offers) do
      add :nft_id, :integer
      add :offer_price, :integer
      add :status, :string
      add :seller, :string
      add :buyer, :string
      add :tx_hash, :string
      add :expired_at, :utc_datetime
      add :filled_at, :utc_datetime
      add :signature, :string

      timestamps()
    end
  end
end
