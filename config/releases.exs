import Config

config :battle_city, BattleCityWeb.Endpoint,
  url: [scheme: "https", host: "clszzyh.xyz", port: 443],
  http: [port: {:system, "PORT"}],
  server: true
