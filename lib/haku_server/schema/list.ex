defmodule HakuServer.Schema.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :nft_id, :integer
    field :price, :integer
    field :status, :string
    field :seller, :string
    field :buyer, :string
    field :tx_hash, :string
    field :expired_at, :utc_datetime
    field :listed_at, :utc_datetime
    field :filled_at, :utc_datetime
    field :signature, :string

    timestamps()
  end

  def changeset(list, attrs) do
    list
    |> cast(attrs, [:nft_id, :price, :status, :seller, :buyer, :tx_hash, :expired_at, :listed_at, :filled_at, :signature])
    |> validate_required([:nft_id, :price, :status, :seller, :expired_at, :listed_at, :signature])
  end
end
