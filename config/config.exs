# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :battle_city_ui,
  ecto_repos: [BattleCityUi.Repo]

config :battle_city_ui,
  basic_auth: [
    username: "admin",
    password: "admin"
  ]

config :battle_city,
  callback_module: BattleCityUi.GameHandler,
  telemetry_logger: false

# Configures the endpoint
config :battle_city_ui, BattleCityUiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "aHvG40RjqX9E6+zE9sBWJ6N32bcBcfg/jEvywAtN62TGP3fiHxMaYhcHuJcbL/F/",
  render_errors: [view: BattleCityUiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BattleCityUi.PubSub,
  live_view: [signing_salt: "bx+uHC/t"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
