defmodule HakuServer.Repo do
  use Ecto.Repo,
    otp_app: :haku_server,
    adapter: Ecto.Adapters.Postgres
end
