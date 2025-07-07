defmodule HakuServer.List do
  alias HakuServer.Repo
  alias HakuServer.Schema.List
  import Ecto.Query

  # 获取所有 list（分页）
  def list_orders(params \\ %{}) do
    cursor = Map.get(params, "cursor")
    limit = Map.get(params, "limit", 20)
    query =
      from l in List,
        order_by: [desc: l.inserted_at]
    Repo.paginate(query, cursor_fields: [:inserted_at, :id], after: cursor, limit: limit)
  end

  # 创建一个新的 list（NFT 挂单）
  def create_order(attrs) do
    %List{}
    |> List.changeset(attrs)
    |> Repo.insert()
  end
end
