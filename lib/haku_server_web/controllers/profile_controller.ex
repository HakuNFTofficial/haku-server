defmodule HakuServerWeb.ProfileController do
  use HakuServerWeb, :controller
  alias HakuServer.Slice
  alias HakuServer.NFT

  def index(conn, params) do
    # FIXME: Add pagination to the profile
    cursor = params["cursor"]
    limit = (params["limit"] || "50") |> String.to_integer()

    case params["address"] do
      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Address parameter is required"})

      address ->
        profiles = Slice.get_user_profiles(address, cursor, limit)

        render_profiles(conn, profiles)
    end
  end

  def lock(conn, params) do
    %{"address" => address, "nft_id" => nft_id} = params

    case Slice.lock_slices(nft_id, address) do
      {count, _} when count > 0 ->
        conn
        |> put_status(:ok)
        |> json(%{
          success: true,
          message: "Successfully locked #{count} slices",
          locked_count: count
        })

      {0, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          success: false,
          error: "No slices found for the given NFT ID and address"
        })
    end
  end

  def unlock(conn, params) do
    %{"address" => address, "nft_id" => nft_id} = params

    case Slice.unlock_slices(nft_id, address) do
      {count, _} when count > 0 ->
        conn
        |> put_status(:ok)
        |> json(%{
          success: true,
          message: "Successfully unlocked #{count} slices",
          unlocked_count: count
        })

      {0, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          success: false,
          error: "No slices found for the given NFT ID and address"
        })
    end
  end

  defp render_profiles(conn, results) do
    profiles =
      results.entries
      |> Enum.with_index(1)
      |> Enum.map(fn {result, _index} ->
        slices = Slice.get_slices_for_nft(result.nft_id, result.owner)
        nft = NFT.get_nft(result.nft_id)

        %{
          nft_id: result.nft_id,
          count: result.count,
          rarity: nft.rarity,
          coordinates: slices,
          locked: result.locked
        }
      end)

    response = %{
      profiles: profiles,
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
