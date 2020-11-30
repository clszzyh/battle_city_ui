defmodule BattleCity.PowerUp do
  @moduledoc """
  """

  alias BattleCity.Config
  alias BattleCity.Context
  alias BattleCity.Tank

  @type duration :: integer() | :instant

  @type t :: %__MODULE__{__module__: module(), duration: duration()}

  @enforce_keys [:__module__]
  defstruct [
    :__module__,
    duration: Config.power_up_duration()
  ]

  @callback handle_on(Context.t(), Tank.t()) :: BattleCity.inner_callback_tank_result()
  @callback handle_off(Context.t(), Tank.t()) :: BattleCity.inner_callback_tank_result()
  @optional_callbacks handle_off: 2

  defmacro __using__(opt \\ []) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
      alias BattleCity.Context
      alias BattleCity.Tank

      @obj struct!(unquote(__MODULE__), Keyword.put(unquote(opt), :__module__, __MODULE__))
      @spec new :: unquote(__MODULE__).t
      def new, do: @obj
    end
  end

  @spec on(Context.t(), Tank.t(), __MODULE__.t()) :: BattleCity.callback_tank_result()
  def on(%Context{} = ctx, %Tank{} = tank, %__MODULE__{} = powerup) do
    powerup.__module__.handle_on(ctx, tank) |> BattleCity.parse_result(ctx, tank)
  end

  @spec off(Context.t(), Tank.t(), __MODULE__.t()) :: BattleCity.callback_tank_result()
  def off(%Context{} = ctx, %Tank{} = tank, %__MODULE__{} = powerup) do
    if function_exported?(powerup.__module__, :handle_off, 2) do
      powerup.__module__.handle_off(ctx, tank) |> BattleCity.parse_result(ctx, tank)
    else
      {ctx, tank}
    end
  end
end
