defmodule BattleCity.Position do
  @moduledoc false

  @type direction :: :up | :down | :left | :right

  import Integer, only: [is_even: 1]

  @size 12

  @border 4
  @width @border * 2

  @atom 2

  @xmin 0
  @xmax @size * @atom
  @ymin 0
  @ymax @size * @atom
  @xmid round((@xmin + @xmax) * 0.5)
  @x_player_1 round(@xmid - @atom - 0.5 * @atom)

  @rxmin @xmin * @width
  @rxmax @xmax * @width
  @rymin @ymin * @width
  @rymax @ymax * @width

  @x_range @xmin..@xmax
  @y_range @ymin..@ymax
  @diretions [:up, :down, :left, :right]

  @type x :: unquote(@xmin)..unquote(@xmax)
  @type y :: unquote(@ymin)..unquote(@ymax)
  @type rx :: unquote(@rxmin)..unquote(@rxmax)
  @type ry :: unquote(@rymin)..unquote(@rymax)
  @type xy :: {x, y}
  @typep rx_or_ry :: rx | ry
  @typep rx_or_ry_map :: %{(:rx | :ry) => rx_or_ry}
  @type speed :: 1..10
  @typep x_or_y :: x | y
  @typep atom_x_or_y :: :x | :y
  @type path :: {atom_x_or_y, x_or_y}

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
                  ((p.rx == @rxmin and p.direction == :left) or
                     (p.rx == @rxmax and p.direction == :right) or
                     (p.ry == @rymin and p.direction == :up) or
                     (p.ry == @rymax and p.direction == :down))

  @spec init(map) :: __MODULE__.t()
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
    map = map |> Map.merge(%{rx: x * @width, ry: y * @width}) |> Map.take(@keys)
    struct!(__MODULE__, map)
  end

  defp fetch_diretion(:random), do: Enum.random(@diretions)
  defp fetch_x(:x_player_1), do: @x_player_1
  defp fetch_x(:x_random_enemy), do: Enum.random([@xmin, @xmid, @xmax])
  defp fetch_x(:x_random), do: Enum.random(@x_range)
  defp fetch_y(:y_player_1), do: @ymax
  defp fetch_y(:y_random_enemy), do: @ymin
  defp fetch_y(:y_random), do: Enum.random(@y_range)

  def objects, do: @objects
  def size, do: @size
  def atom, do: @atom
  def width, do: @width

  @spec round(__MODULE__.t()) :: xy()
  def round(%__MODULE__{x: x, y: y, direction: direction}) do
    {normalize_number(:x, x, direction), normalize_number(:y, y, direction)}
  end

  @spec normalize_number(:x | :y, x_or_y(), direction()) :: x_or_y()
  defp normalize_number(_, n, _) when is_even(n), do: n
  defp normalize_number(:x, n, :right), do: n + 1
  defp normalize_number(:y, n, :up), do: n + 1
  defp normalize_number(_, n, _), do: n - 1

  @spec vector_with_normalize(__MODULE__.t(), speed) :: {atom_x_or_y, rx_or_ry_map, x_or_y}
  def vector_with_normalize(%{direction: direction} = p, speed) do
    {x_or_y, target} = vector(p, speed)

    map =
      case x_or_y do
        :x -> %{rx: target}
        :y -> %{ry: target}
      end

    {x_or_y, map, normalize_number(x_or_y, div(target, @width), direction)}
  end

  @spec vector(__MODULE__.t(), speed) :: {atom_x_or_y, speed}
  def vector(%{direction: :right, rx: rx}, speed) when rx + speed <= @rxmax, do: {:x, rx + speed}
  def vector(%{direction: :right}, _), do: {:x, @rxmax}
  def vector(%{direction: :left, rx: rx}, speed) when rx - speed >= 0, do: {:x, rx - speed}
  def vector(%{direction: :left}, _), do: {:x, 0}
  def vector(%{direction: :up, ry: ry}, speed) when ry + speed <= @rymax, do: {:y, ry + speed}
  def vector(%{direction: :up}, _), do: {:y, @rymax}
  def vector(%{direction: :down, ry: ry}, speed) when ry - speed >= 0, do: {:y, ry - speed}
  def vector(%{direction: :down}, _), do: {:y, 0}
end
