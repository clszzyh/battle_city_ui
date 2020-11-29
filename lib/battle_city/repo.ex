defmodule BattleCity.Repo do
  use Ecto.Repo,
    otp_app: :battle_city,
    adapter: Ecto.Adapters.Postgres
end
