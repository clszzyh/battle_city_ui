defmodule BattleCity.Environment do
  @moduledoc false

  alias BattleCity.Action
  alias BattleCity.Bullet
  alias BattleCity.Position
  alias BattleCity.Tank

  @typep health :: integer() | :infinite
  @typep shape :: nil | binary()
  @type object :: Tank.t() | Bullet.t()
  @typep enter_result :: {:error, BattleCity.reason()} | {:ok, object}

  @type t :: %__MODULE__{
          __module__: module(),
          id: BattleCity.id(),
          enter?: boolean(),
          health: health,
          shape: shape,
          x: Position.x(),
          y: Position.y(),
          rx: Position.rx(),
          ry: Position.ry()
        }

  @enforce_keys [:enter?, :health]
  defstruct [
    :__module__,
    :id,
    :x,
    :y,
    :rx,
    :ry,
    :shape,
    enter?: false,
    health: 0
  ]

  use BattleCity.StructCollect

  @callback handle_enter(__MODULE__.t(), object) :: enter_result
  @callback handle_leave(__MODULE__.t(), object) :: enter_result

  defmacro __using__(opt \\ []) do
    obj = struct!(__MODULE__, opt)

    quote location: :keep do
      alias BattleCity.Tank
      @impl true
      def handle_enter(_, o), do: {:ok, o}
      @impl true
      def handle_leave(_, o), do: {:ok, o}
      init_ast(unquote(__MODULE__), __MODULE__, unquote(Macro.escape(obj)))
    end
  end

  @spec copy_rxy(__MODULE__.t(), object) :: object
  def copy_rxy(%{rx: rx, ry: ry}, %{position: position} = o) do
    %{o | position: %{position | rx: rx, ry: ry, path: []}}
  end

  @spec copy_xy(__MODULE__.t(), object) :: object
  def copy_xy(%{x: x, y: y}, %{position: %{path: [_ | rest]} = position} = o) do
    %{o | position: %{position | x: x, y: y, path: rest}}
  end

  @spec enter(__MODULE__.t(), object) :: enter_result
  def enter(%__MODULE__{enter?: false}, %Tank{}), do: {:error, :forbidden}
  def enter(%__MODULE__{enter?: false, health: :infinite}, %Bullet{}), do: {:error, :forbidden}

  def enter(
        %__MODULE__{enter?: false, health: health, x: x, y: y, id: env_id},
        %Bullet{__actions__: actions, id: bullet_id} = bullet
      )
      when health > 0 do
    action = %Action{
      target_id: env_id,
      source_id: bullet_id,
      target_type: :environment,
      source_type: :bullet,
      kind: :damage,
      value: 1,
      args: %{x: x, y: y}
    }

    {:ok, %{bullet | dead?: true, __actions__: [action | actions]}}
  end

  def enter(%__MODULE__{__module__: module} = environment, o) do
    module.handle_enter(environment, o)
  end

  @spec leave(__MODULE__.t(), object) :: enter_result
  def leave(%__MODULE__{__module__: module} = environment, o) do
    module.handle_leave(environment, o)
  end
end
