defmodule BattleCity.Position do
  @moduledoc false

  @type direction :: :up | :down | :left | :right

  @x_range 0..12
  @y_range 0..12
  @diretions [:up, :down, :left, :right]

  @type x :: 0..12
  @type y :: 0..12
  @type xy :: {x, y}

  @type t :: %__MODULE__{
          direction: direction(),
          x: x(),
          y: y()
        }

  @keys [:direction, :x, :y]
  @enforce_keys [:direction, :x, :y]
  defstruct [:x, :y, :direction]

  @objects for x <- @x_range, y <- @y_range, do: {{x, y}, MapSet.new()}, into: %{}

  def objects, do: @objects

  def init(map \\ %{})

  def init(%{direction: direction} = map) when direction not in @diretions do
    init(%{map | direction: fetch_diretion(direction)})
  end

  def init(%{x: x} = map) when x not in @x_range do
    init(%{map | x: fetch_x(x)})
  end

  def init(%{y: y} = map) when y not in @y_range do
    init(%{map | y: fetch_y(y)})
  end

  def init(map) do
    struct!(__MODULE__, Map.take(map, @keys))
  end

  defp fetch_diretion(:random), do: Enum.random(@diretions)
  defp fetch_x(:x_player_1), do: 5
  defp fetch_x(:x_random_enemy), do: Enum.random([0, 6, 12])
  defp fetch_x(:x_random), do: Enum.random(@x_range)
  defp fetch_y(:y_player_1), do: 12
  defp fetch_y(:y_random_enemy), do: 0
  defp fetch_y(:y_random), do: Enum.random(@y_range)
end
