defmodule HakuServerWeb.LeaderboardController do
  use HakuServerWeb, :controller
  alias HakuServer.Slice
  alias HakuServer.NFT

  def index(conn, %{"type" => type} = params) do
    # FIXME: Add pagination to the leaderboard
    cursor = params["cursor"]
    limit = (params["limit"] || "50") |> String.to_integer()

    case type do
      "all" ->
        results = Slice.get_leaderboard(cursor, limit)
        render_leaderboard(conn, results)

      "mine" ->
        case params["address"] do
          nil ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "Address parameter is required for 'mine' type"})

          address ->
            results = Slice.get_my_leaderboard(cursor, limit, address)
            render_leaderboard(conn, results)
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid leaderboard type. Use 'all' or 'mine'"})
    end
  end

  defp render_leaderboard(conn, results) do
    nft_ids = Enum.map(results.entries, & &1.nft_id)

    nfts_map = NFT.get_nfts(nft_ids)

    leaderboard =
      results.entries
      |> Enum.map(fn result ->
        slices = Slice.get_slices_for_nft(result.nft_id, result.owner)
        nft = Map.get(nfts_map, result.nft_id)

        %{
          id: result.nft_id,
          owned: result.count,
          rarity: nft.rarity,
          owner: result.owner,
          rank: result.rank,
          coordinates: slices
        }
      end)

    response = %{
      leaderboard: leaderboard,
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
