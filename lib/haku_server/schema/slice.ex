defmodule HakuServer.Schema.Slice do
  use Ecto.Schema
  import Ecto.Changeset

  alias HakuServer.Schema.NFT

  schema "slices" do
    field :owner, :string
    field :locked, :boolean, default: false
    field :x, :integer
    field :y, :integer

    timestamps()

    belongs_to :nft, NFT
  end

  def changeset(slice, attrs) do
    slice
    |> cast(attrs, [:nft_id, :x, :y, :owner, :locked])
    |> validate_required([:nft_id, :x, :y, :owner])
  end
end
