defmodule HakuServerWeb.OfferController do
  use HakuServerWeb, :controller

  alias HakuServer.Offer

  def list(conn, params) do
    page = Offer.list_offers(params)
    conn |> json(%{offers: page.entries, meta: page.meta})
  end

  def create(conn, params) do
    case Offer.create_offer(params) do
      {:ok, offer} ->
        conn |> json(%{offer: offer})
      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset.errors})
    end
  end
end
