import Config

# Configure your database
config :bilancio, Bilancio.Repo,
  username: "bilancio",
  password: "bilancio",
  hostname: "db",
  database: "bilancio",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

if System.get_env("GITHUB_ACTIONS") do
  config :bilancio, Bilancio.Repo,
    username: "postgres",
    password: "postgres",
    hostname: "localhost"
end

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bilancio, BilancioWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "RH7u4PFnHmK6Vx/VvVee1bLFyoG1ud7Fp+0+3Ys2iwFUnfVldG4bGfqDpSOLC776",
  server: false

# In test we don't send emails.
config :bilancio, Bilancio.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :joken, default_signer: "secret"

config :bilancio, :redis, connection_url: "redis://redis:6379/1"

if System.get_env("GITHUB_ACTIONS") do
  config :bilancio, :redis, connection_url: "redis://localhost:6379/1"
end

config :bilancio, :jwt,
  sign: "HS256",
  exp_days: 7
