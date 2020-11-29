defmodule BattleCity.Tank do
  @moduledoc false

  defmodule Base do
    @type health :: 1..10
    @type move_speed :: 1..10
    @type bullet_speed :: move_speed
    @type points :: integer

    @type t :: %__MODULE__{
            __module__: module,
            points: points(),
            health: health(),
            move_speed: move_speed(),
            bullet_speed: bullet_speed()
          }

    @enforce_keys []
    defstruct [
      :__module__,
      :points,
      :health,
      :move_speed,
      :bullet_speed
    ]

    defmacro __using__(opt \\ []) do
      quote location: :keep do
        # @behaviour unquote(__MODULE__)
        alias BattleCity.Tank

        @obj struct!(unquote(__MODULE__), Keyword.put(unquote(opt), :__module__, __MODULE__))
        def new, do: @obj
      end
    end
  end

  @type t :: %__MODULE__{
          tank: Base.t(),
          enemy?: boolean(),
          hiden?: boolean(),
          temp: map()
        }

  defstruct [
    :tank,
    temp: %{},
    enemy?: true,
    hiden?: false
  ]
end
