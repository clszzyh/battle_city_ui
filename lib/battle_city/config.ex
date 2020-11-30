defmodule BattleCity.Config do
  @moduledoc false

  @default_life_count 3
  @default_rest_enemies 20
  @default_power_up_duration 10

  def life_count, do: get_config(:life, @default_life_count)
  def rest_enemies, do: get_config(:rest_enemies, @default_rest_enemies)
  def power_up_duration, do: get_config(:power_up_duration, @default_power_up_duration)

  def get_config(key, default \\ nil) do
    Application.get_env(:battle_city, key, default)
  end
end
