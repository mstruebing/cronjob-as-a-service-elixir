# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :cronjob_as_a_service,
  ecto_repos: [CronjobAsAService.Repo]

# Configures the endpoint
config :cronjob_as_a_service, CronjobAsAServiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gl5AorUOcI60/XpO8r4zzhTPk79qQMeBFQREKVbnn0wNTds6GRkLQ2YfPpmfjsuA",
  render_errors: [view: CronjobAsAServiceWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: CronjobAsAService.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# configures Guardian
config :cronjob_as_a_service, CronjobAsAService.Guardian,
  # optional
  allowed_algos: ["HS512"],
  # optional
  verify_module: Guardian.JWT,
  issuer: "CronjobAsAService",
  ttl: {30, :days},
  allowed_drift: 2000,
  # optional
  verify_issuer: true,
  # generated using: JOSE.JWK.generate_key({:oct, 16}) |> JOSE.JWK.to_map |> elem(1)
  # TODO: CHANGE THIS BEFORE HOSTING
  secret_key: %{"k" => "3gx0vXjUD2BJ8xfo_aQWIA", "kty" => "oct"},
  serializer: CronjobAsAService.Guardian
