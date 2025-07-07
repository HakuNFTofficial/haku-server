defmodule HakuServer.Schema.Offer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "offers" do
    field :nft_id, :integer
    field :offer_price, :integer
    field :status, :string
    field :seller, :string
    field :buyer, :string
    field :tx_hash, :string
    field :expired_at, :utc_datetime

    timestamps()
  end

  def changeset(offer, attrs) do
    offer
    |> cast(attrs, [:nft_id, :offer_price, :status, :seller, :buyer, :tx_hash, :expired_at])
    |> validate_required([:nft_id, :offer_price, :status, :seller, :expired_at])
  end
end
