defmodule BattleCity.Callback do
  @moduledoc false

  # alias BattleCity.Bullet
  alias BattleCity.Business.Generate
  alias BattleCity.Context
  # alias BattleCity.PowerUp
  alias BattleCity.Process.GameSupervisor
  alias BattleCity.Tank

  @typep object_struct :: Context.object_struct()
  @typep action :: :create | :update | :delete

  @spec handle(action, object_struct, Context.t()) :: Context.t()
  def handle(:create, nil, ctx), do: ctx

  def handle(:create, %Tank{enemy?: true, id: id}, ctx) do
    GameSupervisor.start_tank(ctx.slug, id)
    |> case do
      {:ok, _pid} -> ctx
      {:error, _slug} -> ctx
    end
  end

  def handle(:create, _, ctx), do: ctx

  def handle(:update, _, ctx), do: ctx

  def handle(:delete, %Tank{enemy?: true, id: id}, ctx) do
    {_success, _reason} = GameSupervisor.stop_tank(ctx.slug, id)

    ctx
    |> Generate.add_bot(%{bot_count: 1})
    |> case do
      {:error, _reason} -> ctx
      ctx -> ctx
    end
  end

  def handle(:delete, _, ctx), do: ctx
end
