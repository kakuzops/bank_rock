# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bank_rock,
  ecto_repos: [BankRock.Repo]

config :bank_rock, BankRock.Guardian,
  issuer: "bank_rock api",
  secret_key: "GQnxbJ32Sl3gqM7tNU2N/9wDOTL8XreawUkUoL74JAlWJd5a0ugUu9MJzHeO8aIG"

# Configures the endpoint
config :bank_rock, BankRockWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FP/FPhEUSKUh4+FJoLxsByie56q2NlqiihCUkvsBeoSCcFZFrm0d7DuIyRCaks4P",
  render_errors: [view: BankRockWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: BankRock.PubSub,
  live_view: [signing_salt: "1qNBa1Hb"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :rihanna,
  producer_postgres_connection: {Ecto, BankRock.Repo}

config :money,
  default_currency: :BRL

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
