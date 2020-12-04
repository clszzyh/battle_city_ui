defmodule BattleCity.Environment do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Context
  alias BattleCity.Position
  alias BattleCity.Tank

  @typep health :: integer() | :infinite
  @typep shape :: nil | binary()
  @type object :: Tank.t() | Bullet.t()

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

  @callback handle_enter(Context.t(), Tank.t()) :: BattleCity.invoke_tank_result()
  @callback handle_leave(Context.t(), Tank.t()) :: BattleCity.invoke_tank_result()

  @callback handle_hit(Context.t(), Bullet.t()) :: BattleCity.inner_callback_bullet_result()
  @optional_callbacks handle_enter: 2, handle_leave: 2, handle_hit: 2

  defmacro __using__(opt \\ []) do
    obj = struct!(__MODULE__, opt)
    ast = generate_ast(obj)

    quote location: :keep do
      alias BattleCity.Tank
      unquote(ast)

      init_ast(unquote(__MODULE__), __MODULE__, unquote(Macro.escape(obj)))
    end
  end

  @spec on(Context.t(), Tank.t(), __MODULE__.t()) :: BattleCity.invoke_result()
  def on(%Context{} = ctx, %Tank{} = tank, %__MODULE__{} = environment) do
    if function_exported?(environment.__module__, :handle_on, 2) do
      environment.__module__.handle_on(ctx, tank)
      |> BattleCity.parse_tank_result(ctx, tank)
      |> Context.put_object()
    else
      Context.put_object(ctx, tank)
    end
  end

  @spec off(Context.t(), Tank.t(), __MODULE__.t()) :: BattleCity.invoke_result()
  def off(%Context{} = ctx, %Tank{} = tank, %__MODULE__{} = environment) do
    if function_exported?(environment.__module__, :handle_off, 2) do
      environment.__module__.handle_off(ctx, tank)
      |> BattleCity.parse_tank_result(ctx, tank)
      |> Context.put_object()
    else
      Context.put_object(ctx, tank)
    end
  end

  @spec copy_xy(__MODULE__.t(), object) :: {:ok, object}
  def copy_xy(%__MODULE__{x: x, y: y, rx: rx, ry: ry}, %{position: position} = o) do
    {:ok, %{o | position: %{position | x: x, y: y, rx: rx, ry: ry}}}
  end

  @spec enter(__MODULE__.t(), object) :: {:ok, object}
  def enter(%__MODULE__{}, o) do
    {:ok, o}
  end

  @spec leave(__MODULE__.t(), object) :: {:ok, object}
  def leave(%__MODULE__{}, o) do
    {:ok, o}
  end

  defp generate_ast(%__MODULE__{health: :infinite, enter?: false}) do
    quote do
      @impl true
      def handle_hit(_, _), do: :ignored
      @impl true
      def handle_enter(_, _), do: {:error, :forbidden}
    end
  end

  defp generate_ast(%__MODULE__{health: 0, enter?: false}) do
    quote do
      @impl true
      def handle_hit(_, _), do: :ignored
      @impl true
      def handle_enter(_, _), do: {:error, :forbidden}
    end
  end

  defp generate_ast(%__MODULE__{health: 0, enter?: true}) do
    quote do
      @impl true
      def handle_hit(_, _), do: :ignored
      @impl true
      def handle_enter(_, _), do: :ignored
    end
  end

  defp generate_ast(%__MODULE__{health: health, enter?: false}) when health > 0 do
    quote do
      @impl true
      def handle_hit(_, _), do: :ignored
      @impl true
      def handle_enter(_, _), do: :ignored
    end
  end
end
