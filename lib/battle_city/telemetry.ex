defmodule BattleCity.Telemetry do
  @moduledoc false

  require Logger

  @prefix :battle_city
  @handler_id "#{@prefix}-default-logger"

  @events Enum.flat_map([:game_init, :game_event], fn x ->
            [
              [@prefix, x, :start],
              [@prefix, x, :stop],
              [@prefix, x, :exception]
            ]
          end)

  @spec attach_default_logger(Logger.level()) :: :ok | {:error, :already_exists}
  def attach_default_logger(level \\ :info) do
    :telemetry.attach_many(@handler_id, @events, &handle_event/4, level)
  end

  @spec span(name :: atom(), fun :: (() -> {term(), map()}), meta :: map()) :: term()
  def span(name, fun, meta \\ %{}) when is_atom(name) and is_function(fun, 0) do
    :telemetry.span([@prefix, name], meta, fun)
  end

  @spec handle_event([atom()], map(), map(), Logger.level()) :: :ok
  def handle_event([@prefix, kind, event], _, meta, level) do
    Logger.log(level, "#{kind}-#{event} #{inspect(meta)}")
  end
end
