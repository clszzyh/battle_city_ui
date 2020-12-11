defmodule BattleCity.Action do
  @moduledoc false

  alias BattleCity.Context

  @typep kind :: :damage
  @typep value :: number
  @typep id :: BattleCity.id()
  @typep type :: :bullet | :environment

  @type t :: %__MODULE__{
          target_id: id,
          target_type: type,
          source_id: id,
          source_type: type,
          kind: kind,
          value: value,
          args: map
        }

  @enforce_keys [:target_id, :source_id, :target_type, :source_type, :kind, :value, :args]
  defstruct [
    :target_id,
    :target_type,
    :source_id,
    :source_type,
    :kind,
    :value,
    args: %{}
  ]

  @spec handle(Context.t(), __MODULE__.t()) :: Context.t()
  def handle(%Context{stage: %{map: map_data} = stage} = ctx, %__MODULE__{
        target_type: :environment,
        kind: :damage,
        value: value,
        args: %{x: x, y: y}
      }) do
    %{health: health} = environment = Map.fetch!(map_data, {x, y})
    map_data = Map.put(map_data, {x, y}, %{environment | health: health - value})
    %{ctx | stage: %{stage | map: map_data}}
  end
end
