defmodule HakuServer.NFT do
  import Ecto.Query

  alias HakuServer.Repo
  alias HakuServer.Schema.NFT

  def get_nft(id) do
    Repo.get(NFT, id)
  end

  def get_nfts(ids) when is_list(ids) do
    from(n in NFT, where: n.id in ^ids)
    |> Repo.all()
    |> Map.new(&{&1.id, &1})
  end
end
