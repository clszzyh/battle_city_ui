defmodule BattleCityWeb.GamesChannel do
  use BattleCityWeb, :channel

  require Logger

  # alias BattleCityWeb.Presence

  def join("liveview", _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def join(room, params, socket) do
    Logger.info("join room #{room} -> #{inspect(params)}")
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    IO.puts("after_join: #{socket.id}")

    # {:ok, _} =
    #   Presence.track(socket, socket.assigns.user_id, %{
    #     online_at: inspect(System.system_time(:second))
    #   })

    # push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
