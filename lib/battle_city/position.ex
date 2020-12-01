defmodule BattleCity.Position do
  @moduledoc false

  @type direction :: :up | :down | :left | :right
  @type x :: 0..12
  @type y :: 0..12

  @type t :: %__MODULE__{
          direction: direction(),
          x: x(),
          y: y()
        }

  @keys [:direction, :x, :y]

  defstruct direction: :up,
            x: 0,
            y: 0

  def init(map \\ %{})

  def init(%{direction: :random} = map) do
    init(%{map | direction: random_diretion()})
  end

  def init(map) do
    struct!(__MODULE__, Map.take(map, @keys))
  end

  defp random_diretion do
    Enum.random([:up, :down, :left, :right])
  end
end
