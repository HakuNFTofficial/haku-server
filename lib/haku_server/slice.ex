defmodule HakuServer.Slice do
  import Ecto.Query
  alias HakuServer.Repo
  alias HakuServer.Schema.Slice
  alias HakuServer.Schema.NFT

  def assign_random_slices(count, address) do
    address = String.downcase(address)
    # sql = """
    # UPDATE slices
    # SET owner = $1
    # WHERE id IN (
    #   SELECT id FROM slices WHERE owner IS NULL AND locked = false ORDER BY RANDOM() LIMIT $2
    # )
    # """
    # Ecto.Adapters.SQL.query!(Repo, sql, [address, count])

    ids_query = """
    SELECT id FROM slices WHERE owner IS NULL AND locked = false LIMIT $1
    """

    {:ok, %{rows: rows}} = Ecto.Adapters.SQL.query(Repo, ids_query, [100_000])
    ids = Enum.map(rows, &hd/1) |> Enum.take_random(count)

    # 2. update 这些 id
    if ids != [] do
      update_query = """
      UPDATE slices SET owner = $1, updated_at = NOW() WHERE id = ANY($2)
      """

      Ecto.Adapters.SQL.query!(Repo, update_query, [address, ids])
    end
  end

  # leaderboard for all users
  def get_leaderboard(cursor \\ nil, limit \\ 50) do
    query =
      from s in Slice,
        where: not is_nil(s.owner),
        group_by: [s.nft_id, s.owner],
        select: %{
          nft_id: s.nft_id,
          owner: s.owner,
          count: count(s.id),
          rank: fragment("ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC)")
        }

    Repo.paginate(query, cursor_fields: [:count, :nft_id], after: cursor, limit: limit)
  end

  # leaderboard for a specific user
  def get_my_leaderboard(cursor \\ nil, limit \\ 50, address) do
    address = String.downcase(address)

    query =
      from s in Slice,
        where: s.owner == ^address,
        group_by: [s.nft_id, s.owner],
        select: %{
          nft_id: s.nft_id,
          owner: s.owner,
          count: count(s.id),
          rank: fragment("ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC)")
        }

    Repo.paginate(query, cursor_fields: [:count, :nft_id], after: cursor, limit: limit)
  end

  def get_slices_for_nft(nft_id, owner) do
    from(s in Slice,
      where: s.nft_id == ^nft_id and s.owner == ^owner,
      select: %{
        x: s.x,
        y: s.y
      },
      order_by: [s.x, s.y]
    )
    |> Repo.all()
  end

  # nfts owned by an address
  def get_complete_nfts(address, cursor \\ nil, limit \\ 50) do
    # FIXME: Add pagination to the nft
    address = String.downcase(address)

    query =
      from s in Slice,
        where: s.owner == ^address,
        group_by: [s.nft_id, s.owner],
        having: count(s.id) == 10_000,
        select: %{
          nft_id: s.nft_id,
          owned_count: count(s.id),
          owner: s.owner
        }

    Repo.paginate(query, cursor_fields: [:rarity, :nft_id], after: cursor, limit: limit)
  end

  # TODO: implement this
  def burn_nft(nft_id, address) do
    from(n in NFT,
      where: n.id == ^nft_id and fragment("LOWER(?) = LOWER(?)", n.owner, ^address),
      update: [set: [owner: nil]]
    )
    |> Repo.update_all([])
  end

  # TODO: implement this
  def mint_nft(nft_id, address) do
    from(n in NFT,
      where: n.id == ^nft_id,
      update: [set: [owner: ^address]]
    )
    |> Repo.update_all([])
  end

  # user profile
  def get_user_profiles(address, cursor \\ nil, limit \\ 50) do
    # FIXME: Add pagination to the profile
    query =
      from s in Slice,
        where: fragment("LOWER(?) = LOWER(?)", s.owner, ^address),
        group_by: [s.nft_id, s.owner, s.locked],
        select: %{
          nft_id: s.nft_id,
          owner: s.owner,
          count: count(s.id),
          locked: s.locked
        },
        order_by: [desc: count(s.id)]

    Repo.paginate(query, cursor_fields: [:count, :nft_id], after: cursor, limit: limit)
  end

  # user profile lock slices
  def lock_slices(nft_id, address) do
    address = String.downcase(address)

    from(s in Slice,
      where: s.nft_id == ^nft_id and s.owner == ^address,
      update: [set: [locked: true]]
    )
    |> Repo.update_all([])
  end

  # user profile unlock slices
  def unlock_slices(nft_id, address) do
    address = String.downcase(address)

    from(s in Slice,
      where: s.nft_id == ^nft_id and s.owner == ^address,
      update: [set: [locked: false]]
    )
    |> Repo.update_all([])
  end

  def get_marketplace_slices(nft_id, cursor \\ nil, limit \\ 50) do
    query =
      from(s in Slice,
        where: s.nft_id == ^nft_id and is_nil(s.owner),
        select: %{
          x: s.x,
          y: s.y
        }
      )

    Repo.paginate(query, cursor_fields: [:x, :y], after: cursor, limit: limit)
  end

  def get_slice_counts_by_nft(address, cursor \\ nil, limit \\ 50) do
    query =
      from(s in Slice,
        join: n in NFT,
        on: s.nft_id == n.id,
        where: fragment("LOWER(?) = LOWER(?)", s.owner, ^address),
        group_by: [s.nft_id, n.rarity],
        select: %{
          nft_id: s.nft_id,
          rarity: n.rarity,
          count: count(s.id)
        },
        order_by: [desc: count(s.id)]
      )

    Repo.paginate(query, cursor_fields: [:count, :nft_id], after: cursor, limit: limit)
  end

  def get_owner_rank(address) do
    # Get total slice count for all owners, ordered by count
    owners_with_counts =
      from(s in Slice,
        where: not is_nil(s.owner),
        group_by: s.owner,
        select: %{
          owner: s.owner,
          total_count: count(s.id)
        },
        order_by: [desc: count(s.id)]
      )
      |> Repo.all()

    # Find the owner's position in the list
    address_downcased = String.downcase(address)

    {rank, total_count} =
      Enum.reduce_while(Enum.with_index(owners_with_counts, 1), {nil, nil}, fn {%{
                                                                                  owner: owner,
                                                                                  total_count:
                                                                                    count
                                                                                }, index},
                                                                               _acc ->
        if String.downcase(owner) == address_downcased do
          {:halt, {index, count}}
        else
          {:cont, {nil, nil}}
        end
      end)

    # Return the rank and total count
    %{
      rank: rank,
      total_count: total_count,
      total_owners: length(owners_with_counts)
    }
  end

  def get_slices_for_nfts(nft_ids, owners) do
    from(s in Slice,
      where: s.nft_id in ^nft_ids and s.owner in ^owners,
      select: %{nft_id: s.nft_id, x: s.x, y: s.y}
    )
    |> Repo.all()
    |> Enum.group_by(& &1.nft_id)
  end
end
