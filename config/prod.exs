import Config

# Configure your database
config :grabakey, Grabakey.Repo,
  database: Path.expand("../grabakey_prod.db", Path.dirname(__ENV__.file)),
  pool_size: 5

# Do not print debug messages in production
config :logger, level: :info

config :swoosh, local: false
