defmodule BattleCity.Bullet do
  @moduledoc false

  @type t :: %__MODULE__{speed: integer}

  defstruct [
    :speed
  ]
end
