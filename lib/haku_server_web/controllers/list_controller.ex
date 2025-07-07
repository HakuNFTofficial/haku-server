defmodule HakuServerWeb.ListController do
  use HakuServerWeb, :controller

  alias HakuServer.List

  def list(conn, params) do
    page = List.list_orders(params)
    conn |> json(%{orders: page.entries, meta: page.meta})
  end

  def create(conn, params) do
    case List.create_order(params) do
      {:ok, order} ->
        conn |> json(%{order: order})
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset.errors})
    end
  end
end
