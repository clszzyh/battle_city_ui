defmodule BattleCity.Stage do
  @moduledoc false

  @type level :: integer

  @type t :: %__MODULE__{level: level()}

  defstruct [
    :level
  ]
end
