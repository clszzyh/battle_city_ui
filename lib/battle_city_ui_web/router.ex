defmodule BattleCityUiWeb.Router do
  use BattleCityUiWeb, :router

  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BattleCityUiWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :set_name do
    plug BattleCityUiWeb.SetName
  end

  pipeline :admin_only do
    plug :basic_auth, Application.compile_env(:battle_city_ui, :basic_auth)
  end

  scope "/", BattleCityUiWeb do
    pipe_through [:browser, :set_name]

    live "/", GameLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", BattleCityUiWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test, :prod] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:browser, :admin_only]

      live_dashboard "/dashboard",
        metrics: BattleCityUiWeb.Telemetry,
        ecto_repos: [BattleCityUi.Repo],
        metrics_history: {BattleCityUi.TelemetryStorage, :metrics_history, []},
        allow_destructive_actions: true,
        additional_pages: [
          process_registry: BattleCityUiWeb.LiveDashboard.ProcessRegistryPage,
          game_servers: BattleCityUiWeb.LiveDashboard.GameServersPage,
          stages: BattleCityUiWeb.LiveDashboard.StagesPage,
          presence: BattleCityUiWeb.LiveDashboard.PresencePage,
          os_processes: BattleCityUiWeb.LiveDashboard.OsProcessesPage
        ]
    end
  end
end
