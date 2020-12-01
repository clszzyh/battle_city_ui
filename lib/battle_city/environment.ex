defmodule BattleCity.Environment do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Context
  alias BattleCity.Tank
  alias __MODULE__

  @type health :: integer() | :infinite
  @type shape :: nil | binary()

  @type t :: %__MODULE__{
          __module__: module(),
          enter?: boolean(),
          health: health,
          shape: shape
        }

  defstruct [
    :__module__,
    enter?: false,
    health: 0,
    shape: nil
  ]

  @callback handle_enter(Context.t(), Tank.t()) :: BattleCity.inner_callback_tank_result()
  @callback handle_leave(Context.t(), Tank.t()) :: BattleCity.inner_callback_tank_result()

  @callback handle_hit(Context.t(), Bullet.t()) :: BattleCity.inner_callback_bullet_result()
  @optional_callbacks handle_enter: 2, handle_leave: 2, handle_hit: 2

  defmacro __using__(opt \\ []) do
    obj = struct!(__MODULE__, opt)
    ast = generate_ast(obj)

    quote location: :keep do
      @behaviour unquote(__MODULE__)
      alias BattleCity.Tank

      @obj Map.put(unquote(Macro.escape(obj)), :__module__, __MODULE__)

      unquote(ast)

      @spec new(Environment.shape()) :: unquote(__MODULE__).t
      def new(shape \\ nil)
      def new(nil), do: @obj
      def new(shape), do: Map.put(@obj, :shape, shape)

      defoverridable unquote(__MODULE__)
    end
  end

  @spec on(Context.t(), Tank.t(), __MODULE__.t()) :: BattleCity.callback_tank_result()
  def on(%Context{} = ctx, %Tank{} = tank, %__MODULE__{} = environment) do
    if function_exported?(environment.__module__, :handle_on, 2) do
      environment.__module__.handle_on(ctx, tank) |> BattleCity.parse_result(ctx, tank)
    else
      {ctx, tank}
    end
  end

  @spec off(Context.t(), Tank.t(), __MODULE__.t()) :: BattleCity.callback_tank_result()
  def off(%Context{} = ctx, %Tank{} = tank, %__MODULE__{} = environment) do
    if function_exported?(environment.__module__, :handle_off, 2) do
      environment.__module__.handle_off(ctx, tank) |> BattleCity.parse_result(ctx, tank)
    else
      {ctx, tank}
    end
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
