defmodule BattleCityWeb.GameLive do
  use BattleCityWeb, :live_view
  alias BattleCity.Context
  alias BattleCity.Process.StageCache
  require Logger

  @default_level "1"

  @impl true
  def mount(%{"level" => level}, _session, socket) do
    inner_mount(level, socket)
  end

  def mount(_params, _session, socket) do
    inner_mount(@default_level, socket)
  end

  defp inner_mount(level, socket) do
    Logger.debug("Mounting! #{level}")
    if connected?(socket), do: Logger.debug("Connected. #{level}")

    ctx = level |> StageCache.fetch_stage() |> Context.init()
    {:ok, assign(socket, ctx: ctx)}
  end

  # @impl true
  # def handle_event("window_key_event", "ArrowUp", socket) do
  #   {:noreply, assign(socket, :y_origin, socket.assigns.y_origin + 1)}
  # end
end
