defmodule BattleCity.Ai do
  @moduledoc false

  alias BattleCity.Context
  alias BattleCity.Event
  alias BattleCity.Tank

  @typep maybe_event :: Event.t() | nil

  @type t :: %__MODULE__{
          slug: BattleCity.slug(),
          id: BattleCity.id(),
          interval: integer,
          loop: boolean(),
          pid: pid(),
          move_event: maybe_event,
          shoot_event: maybe_event
        }

  @enforce_keys [:slug, :id, :interval, :loop]
  defstruct [:slug, :id, :interval, :loop, :pid, :move_event, :shoot_event]

  @callback name :: binary()
  @callback handle_move(Context.t(), Tank.t(), maybe_event) :: maybe_event
  @callback handle_shoot(Context.t(), Tank.t(), maybe_event) :: maybe_event

  defmacro __using__(_opts) do
    quote location: :keep do
      alias BattleCity.Context
      alias BattleCity.Event
      alias BattleCity.Tank

      @behaviour unquote(__MODULE__)
    end
  end

  @spec move(Context.t(), Tank.t() | nil, maybe_event) :: maybe_event
  def move(_, nil, _), do: nil
  def move(_, %Tank{dead?: true}, _), do: nil
  def move(_, %Tank{freezed?: true}, _), do: nil

  def move(ctx, tank, event),
    do: ctx.ai.handle_move(ctx, tank, event) |> handle_result(ctx, event)

  @spec shoot(Context.t(), Tank.t() | nil, maybe_event) :: maybe_event
  def shoot(_, nil, _), do: nil
  def shoot(_, %Tank{dead?: true}, _), do: nil
  def shoot(_, %Tank{shootable?: false}, _), do: nil

  def shoot(ctx, tank, event),
    do: ctx.ai.handle_shoot(ctx, tank, event) |> handle_result(ctx, event)

  defp handle_result(nil, _, _), do: nil
  defp handle_result(%Event{} = event, _, _), do: event
end
