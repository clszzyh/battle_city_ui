defmodule BattleCity.Position do
  @moduledoc false

  @type direction :: :up | :down | :left | :right

  import Integer, only: [is_even: 1]

  @size 12

  @border 4
  @width_real @border * 2

  @atom 2

  @xmin 0
  @xmax @size * @atom
  @ymin 0
  @ymax @size * @atom
  @xmid round((@xmin + @xmax) * 0.5)
  @x_player_1 round(@xmid - @atom - 0.5 * @atom)

  @xmin_real @xmin * @width_real
  @xmax_real @xmax * @width_real
  @ymin_real @ymin * @width_real
  @ymax_real @ymax * @width_real

  @x_range @xmin..@xmax
  @y_range @ymin..@ymax
  @diretions [:up, :down, :left, :right]

  @type x :: unquote(@xmin)..unquote(@xmax)
  @type y :: unquote(@ymin)..unquote(@ymax)
  @type xy :: {x, y}
  @type speed :: 1..10
  @typep x_or_y :: x | y

  @type t :: %__MODULE__{
          direction: direction(),
          x: x(),
          y: y()
        }

  @keys [:direction, :x, :y, :rx, :ry]
  @enforce_keys [:direction, :x, :y, :rx, :ry]
  defstruct [:x, :y, :direction, :rx, :ry]

  @objects for x <- @x_range,
               y <- @y_range,
               rem(x, 2) == 0,
               rem(y, 2) == 0,
               do: {{x, y}, MapSet.new()},
               into: %{}

  defguard is_on_border(p)
           when is_struct(p, __MODULE__) and
                  ((p.rx == @xmin_real and p.direction == :left) or
                     (p.rx == @xmax_real and p.direction == :right) or
                     (p.ry == @ymin_real and p.direction == :up) or
                     (p.ry == @ymax_real and p.direction == :down))

  def objects, do: @objects
  def size, do: @size
  def atom, do: @atom

  @spec round(__MODULE__.t()) :: xy()
  def round(%__MODULE__{x: x, y: y, direction: direction}) do
    {round_number(:x, x, direction), round_number(:y, y, direction)}
  end

  @spec round_number(:x | :y, x_or_y(), direction()) :: x_or_y()
  defp round_number(_, n, _) when is_even(n), do: n
  defp round_number(:x, n, :right), do: n + 1
  defp round_number(:y, n, :up), do: n + 1
  defp round_number(_, n, _), do: n - 1

  def init(map \\ %{})

  def init(%{direction: direction} = map) when direction not in @diretions do
    init(%{map | direction: fetch_diretion(direction)})
  end

  def init(%{x: x} = map) when is_atom(x) do
    init(%{map | x: fetch_x(x)})
  end

  def init(%{y: y} = map) when is_atom(y) do
    init(%{map | y: fetch_y(y)})
  end

  def init(%{x: x, y: y} = map) do
    map = map |> Map.merge(%{rx: x * @width_real, ry: y * @width_real}) |> Map.take(@keys)
    struct!(__MODULE__, map)
  end

  defp fetch_diretion(:random), do: Enum.random(@diretions)
  defp fetch_x(:x_player_1), do: @x_player_1
  defp fetch_x(:x_random_enemy), do: Enum.random([@xmin, @xmid, @xmax])
  defp fetch_x(:x_random), do: Enum.random(@x_range)
  defp fetch_y(:y_player_1), do: @ymax
  defp fetch_y(:y_random_enemy), do: @ymin
  defp fetch_y(:y_random), do: Enum.random(@y_range)
end
