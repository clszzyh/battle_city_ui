defmodule BattleCity.Environment do
  @moduledoc false

  alias BattleCity.Bullet
  alias BattleCity.Context
  alias BattleCity.Tank

  @type health :: integer() | :infinite

  @type t :: %__MODULE__{
          __module__: module(),
          allow_pass_tank: boolean(),
          health: health
        }

  @enforce_keys [:__module__]
  defstruct [
    :__module__,
    allow_pass_tank: false,
    health: :infinite
  ]

  @callback handle_enter(Context.t(), Tank.t()) :: BattleCity.inner_callback_tank_result()
  @callback handle_leave(Context.t(), Tank.t()) :: BattleCity.inner_callback_tank_result()

  @callback handle_hit(Context.t(), Bullet.t()) :: BattleCity.inner_callback_bullet_result()
  @optional_callbacks handle_enter: 2, handle_leave: 2, handle_hit: 2

  defmacro __using__(opt \\ []) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
      alias BattleCity.Tank

      @obj struct!(unquote(__MODULE__), Keyword.put(unquote(opt), :__module__, __MODULE__))

      unless @obj.allow_pass_tank do
        def handle_enter(_, _), do: {:error, :forbidden}
      end

      if @obj.health == :infinite do
        def handle_hit(_, _), do: {:error, :ignored}
      end

      @spec new :: unquote(__MODULE__).t
      def new, do: @obj

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
end
