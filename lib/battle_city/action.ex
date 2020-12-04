defmodule BattleCity.Action do
  @moduledoc false

  @typep kind :: :damage
  @typep value :: term
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

  defstruct [
    :target_id,
    :target_type,
    :source_id,
    :source_type,
    :kind,
    :value,
    args: %{}
  ]
end
