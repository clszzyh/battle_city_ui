defmodule BattleCityWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :battle_city

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_battle_city_key",
    signing_salt: "yLjkCuPg"
  ]

  socket "/socket", BattleCityWeb.UserSocket,
    websocket: [compress: true],
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [
      compress: true,
      connect_info: [:user_agent, :peer_data, session: @session_options]
    ]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.

  if Mix.env() == :prod do
    plug Plug.Static,
      at: "/",
      from: :battle_city,
      gzip: true,
      only: ~w(css fonts images js favicon.ico robots.txt)
  else
    plug Plug.Static,
      at: "/",
      from: :battle_city,
      gzip: false,
      only: ~w(css fonts images js favicon.ico robots.txt)
  end

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :battle_city
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug BattleCityWeb.Router
end
