# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HakuServer.Repo.insert!(%HakuServer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HakuServer.Repo.insert!(%HakuServer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias HakuServer.Repo
alias HakuServer.Schema.NFT
alias HakuServer.Schema.Slice

# generate nfts data
nfts =
  for i <- 0..9999 do
    %{
      url: "https://example.com/nft/#{i + 1}.jpg",
      rarity: i + 1,
      owner: nil,
      metadata: %{
        name: "NFT ##{i + 1}",
        description: "This is NFT number #{i + 1}"
      },
      metadata_url: "https://example.com/nft/#{i + 1}.json",
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }
  end

# insert seeds for nfts
Enum.chunk_every(nfts, 1000)
|> Enum.each(fn chunk -> Repo.insert_all(NFT, chunk) end)

# generate slices data
total_nfts = 10000
total_slices_per_nft = 10000
chunk_size = 5000

IO.puts("Starting slices data generation and insertion...")

for nft_index <- 0..(total_nfts - 1) do
  IO.puts("Processing NFT #{nft_index + 1}/#{total_nfts}")

  slices =
    for j <- 0..(total_slices_per_nft - 1) do
      %{
        nft_id: nft_index + 1,
        x: rem(j, 100),
        y: div(j, 100),
        owner: nil,
        locked: false,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    end

  # Insert slices in smaller chunks
  slices
  |> Enum.chunk_every(chunk_size)
  |> Enum.with_index()
  |> Enum.each(fn {chunk, chunk_index} ->
    try do
      {n, _} = Repo.insert_all(Slice, chunk)
      IO.puts("  Inserted chunk #{chunk_index + 1} (#{n} records)")
    rescue
      e ->
        IO.puts("  Error inserting chunk #{chunk_index + 1}: #{inspect(e)}")
    end
  end)
end

IO.puts("Finished slices data insertion")
