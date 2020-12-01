defmodule BattleCity.Event do
  @moduledoc false

  alias BattleCity.Position

  @type name :: :shoot | :move

  @type t :: %__MODULE__{
          id: BattleCity.id(),
          name: name(),
          keyboard: binary(),
          position: Position.t(),
          args: map()
        }

  @enforce_keys [:id, :name, :keyboard, :args, :position]
  defstruct [
    :id,
    :name,
    :keyboard,
    :position,
    args: %{}
  ]
end
