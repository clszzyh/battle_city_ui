defmodule BattleCity.Event do
  @moduledoc false

  @typep name :: :shoot | :move

  @type t :: %__MODULE__{
          id: BattleCity.id(),
          name: name(),
          keyboard: binary(),
          args: map()
        }

  @enforce_keys [:id, :name, :keyboard, :args]
  defstruct [
    :id,
    :name,
    :keyboard,
    args: %{}
  ]
end
