defmodule BattleCity.Event do
  @moduledoc false

  alias BattleCity.Position

  @type name :: :shoot | :move | :pause | :resume

  @type t :: %__MODULE__{
          name: name(),
          keyboard: binary(),
          position: Position.t(),
          args: map()
        }

  @enforce_keys [:name, :keyboard, :args, :position]
  defstruct [
    :name,
    :keyboard,
    :position,
    args: %{}
  ]
end
