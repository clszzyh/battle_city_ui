defmodule BattleCity.Game do
  @moduledoc false

  alias BattleCity.Business.Generate
  alias BattleCity.Business.Location
  alias BattleCity.Business.Overlap
  alias BattleCity.Context
  alias BattleCity.Event
  alias BattleCity.Position
  alias BattleCity.Process.StageCache
  alias BattleCity.Tank
  require Logger

  @default_stage 1

  @spec init(BattleCity.slug(), map()) :: Context.t()
  def init(slug, opts \\ %{}) do
    module = opts |> Map.get(:stage, @default_stage) |> StageCache.fetch_stage()
    stage = module.init(opts)
    tank = opts |> Map.get(:player_tank, Tank.Level1)

    player =
      opts
      |> Map.merge(%{enemy?: false, x: :x_player_1, y: :y_player_1, direction: :up})
      |> tank.new()

    Logger.debug("[Init] #{slug}")

    %Context{slug: slug, stage: stage, objects: Position.objects()}
    |> Context.put_object(player)
    |> Generate.add_bot(opts)
  end

  @spec loop(Context.t()) :: Context.t()
  def loop(%Context{} = ctx) do
    Logger.debug("[Loop] #{ctx.slug}")
    ctx |> Location.move_all() |> Overlap.resolve()
  end

  @spec handle_event(Context.t(), Event.t()) :: Context.t()
  def handle_event(%Context{} = ctx, %Event{}) do
    Logger.debug("[Event] #{ctx.slug}")
    ctx
  end
end
