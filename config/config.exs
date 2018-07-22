# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :live_transit,
  ecto_repos: [LiveTransit.Repo]

# Configures the endpoint
config :live_transit, LiveTransitWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wAtlXnPdQ+2WCs44LBAiqFoFLXvM3hK/WSNet2ppZ7Bty6+/85E/qFdFTEDJp//3",
  render_errors: [view: LiveTransitWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LiveTransit.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures scrapable feed
config :live_transit, LiveTransit.RealTimeFeed,
  realtime_feed_url: System.get_env("LIVE_TRANSIT_REALTIME_FEED_URL")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
