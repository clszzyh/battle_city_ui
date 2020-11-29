# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :battle_city,
  ecto_repos: [BattleCity.Repo]

# Configures the endpoint
config :battle_city, BattleCityWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "mn4tB4kMqiNd2K2VkihXLQyRDUmaHxuzxqTP0Ma8PrU/k4oXFzPSxTe4sGO+qDNs",
  render_errors: [view: BattleCityWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BattleCity.PubSub,
  live_view: [signing_salt: "0HaGcIW2"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
