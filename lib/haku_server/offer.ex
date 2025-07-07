defmodule HakuServer.Offer do
  alias HakuServer.Repo
  alias HakuServer.Schema.Offer
  import Ecto.Query

  # 获取某 NFT 的所有 offer，支持分页
  def list_offers(params \\ %{}) do
    nft_id = Map.get(params, "nft_id")
    cursor = Map.get(params, "cursor")
    limit = Map.get(params, "limit", 20)
    query =
      from o in Offer,
        where: ^is_nil(nft_id) or o.nft_id == ^nft_id,
        order_by: [desc: o.inserted_at]
    Repo.paginate(query, cursor_fields: [:inserted_at, :id], after: cursor, limit: limit)
  end

  # 创建一个新的 offer
  def create_offer(attrs) do
    %Offer{}
    |> Offer.changeset(attrs)
    |> Repo.insert()
  end
end
