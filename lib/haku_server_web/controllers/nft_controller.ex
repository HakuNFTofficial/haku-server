defmodule HakuServerWeb.NftController do
  use HakuServerWeb, :controller
  alias HakuServer.Slice
  alias HakuServer.NFT

  def index(conn, params) do
    case params["address"] do
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Address parameter is required"})

      address ->
        cursor = params["cursor"]
        limit = (params["limit"] || "50") |> String.to_integer()

        results = Slice.get_complete_nfts(address, cursor, limit)
        render_nfts(conn, results)
    end
  end

  def mint(conn, %{"nft_id" => nft_id, "address" => address}) do
    # FIXME: Mint an NFT
    conn
    |> put_status(:ok)
    |> json(%{success: true})
  end

  def burn(conn, %{"nft_id" => nft_id, "address" => address}) do
    # FIXME: Burn an NFT
    conn
    |> put_status(:ok)
    |> json(%{success: true})
  end

  defp render_nfts(conn, results) do
    nft_ids = Enum.map(results.entries, & &1.nft_id)
    nfts_map = NFT.get_nfts(nft_ids)

    nfts =
      results.entries
      |> Enum.map(fn result ->
        slices = Slice.get_slices_for_nft(result.nft_id, result.owner)
        nft = Map.get(nfts_map, result.nft_id)

        %{
          id: result.nft_id,
          rarity: nft && nft.rarity,
          total: 10_000,
          owned: result.owned_count,
          minted: not is_nil(nft.owner),
          coordinates: Enum.map(slices, &%{x: &1.x, y: &1.y})
        }
      end)

    response = %{
      nfts: nfts,
      pagination: %{
        after: results.metadata.after,
        before: results.metadata.before,
        limit: results.metadata.limit
      }
    }

    conn
    |> put_status(:ok)
    |> json(response)
  end
end
