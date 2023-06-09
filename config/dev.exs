import Config

# Configure your database
config :grabakey, Grabakey.Repo,
  database: Path.expand("../grabakey_dev.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
