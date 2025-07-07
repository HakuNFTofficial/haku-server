defmodule HakuServer.Oban.AssignSlices do
  @moduledoc """
  Assigns slices to a job based on the number of slices and the job's index.
  """
  use Oban.Worker, queue: :default
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"tx" => tx}, meta: meta}) do
    Logger.info("Assigning slices for job with tx: #{tx}")
    Logger.info("Job meta: #{inspect(meta)}")
    assign_slices(tx)

    :ok
  end

  defp assign_slices(tx) do
    Logger.info("transaction hash: #{inspect(tx)}")

    with {:ok, %{"from" => from, "logs" => logs}} <- Ethers.get_transaction_receipt(tx) do
      Logger.info("get_transaction_receipt: #{inspect(from)}, #{inspect(logs)}")
      %{"data" => data} = logs |> List.first()
      Logger.info("data: #{inspect(data)}")
      {:ok, hex} = Ethers.Utils.hex_to_integer(data)
      amount = Ethers.Utils.from_wei(hex) |> trunc()
      Logger.info("amount: #{amount}, from: #{from}")
      HakuServer.Slice.assign_random_slices(amount, from)
    end
  end
end
