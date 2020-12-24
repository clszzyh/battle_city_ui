defmodule BattleCityUi.Repo do
  use Ecto.Repo,
    otp_app: :battle_city_ui,
    adapter: Ecto.Adapters.Postgres
end
