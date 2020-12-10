defmodule BattleCity.Event do
  @moduledoc false

  @typep name :: :shoot | :move | :toggle_pause
  @typep value :: term()

  @type t :: %__MODULE__{
          id: BattleCity.id() | nil,
          name: name(),
          value: value(),
          keyboard: binary() | nil,
          args: map()
        }

  @enforce_keys [:name, :value]
  defstruct [
    :id,
    :name,
    :value,
    :keyboard,
    args: %{}
  ]
end
