defmodule HakuServerWeb.SliceController do
  use HakuServerWeb, :controller

  alias HakuServer.Oban.AssignSlices
  alias HakuServerWeb

  def assign(conn, params) do
    case params do
      %{"tx" => tx} ->
        # Enqueue the slice assignment job
        insert_oban_job(tx)

        conn
        |> put_status(:accepted)
        |> json(%{
          success: true,
          message: "Slice assignment job enqueued"
        })

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          success: false,
          error: "Transaction hash (tx) parameter is required"
        })
    end
  end

  defp insert_oban_job(tx) do
    states = [:available, :scheduled, :executing, :retryable, :completed]

    %{
      tx: tx
    }
    |> AssignSlices.new(
      unique: [fields: [:args], keys: [:tx], period: 60, states: states],
      meta: %{
        tx: tx
      }
    )
    |> Oban.insert()
  end
end
