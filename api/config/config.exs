# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bilancio,
  ecto_repos: [Bilancio.Repo]

# Configures the endpoint
config :bilancio, BilancioWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: BilancioWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bilancio.PubSub,
  live_view: [signing_salt: "fyaMUAYy"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :bilancio, Bilancio.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :bilancio,
  amqp_connection: [
    username: "bilancio",
    password: "bilancio",
    host: "rabbit",
    virtual_host: "bilancio",
    heartbeat: 30,
    connection_timeout: 10_000
  ]

user_deactivated_consumer = %{
  backoff: 1000,
  prefetch_count: 100,
  handler_module: Elixir.Bilancio.Rabbit.Consumer.UserDeactivated
}

config :bilancio,
  consumers: [
    user_deactivated_consumer,
    user_deactivated_consumer,
    user_deactivated_consumer
  ]

config :bilancio, Elixir.Bilancio.Rabbit.Consumer.UserDeactivated, %{
  exchanges: [
    %{
      name: "entity",
      opts: [durable: true],
      routing_keys: ["bilancio.user_deactivated"],
      type: :topic
    }
  ],
  opts: [
    durable: true,
    arguments: [
      {"x-dead-letter-exchange", :longstr, "bilancio_errors"}
    ]
  ],
  queue: "bilancio_user_deactivated"
}

config :bilancio, :producer, %{
  publisher_confirms: true,
  publish_timeout: 10_000,
  exchanges: [
    %{
      name: "entity",
      type: :topic,
      opts: [durable: true]
    }
  ]
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
