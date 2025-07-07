defmodule HakuServer.Schema.NFT do
  use Ecto.Schema

  alias HakuServer.Schema.Slice

  schema "nfts" do
    field :url, :string
    field :rarity, :integer
    field :owner, :string
    field :metadata, :map
    field :metadata_url, :string

    timestamps()

    has_many :slices, Slice
  end
end
