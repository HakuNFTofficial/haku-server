defmodule HakuServerWeb.MarketplaceController do
  use HakuServerWeb, :controller
  alias HakuServer.Slice

  def index(conn, params) do
    nft_id = params["nft_id"]
    cursor = params["cursor"]
    limit = (params["limit"] || "50") |> String.to_integer()

    slices = Slice.get_marketplace_slices(nft_id, cursor, limit)

    conn
    |> put_status(:ok)
    |> json(slices)
  end
end
