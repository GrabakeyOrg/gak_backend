import Config

port = System.get_env("GAK_SERVER_PORT", "31681")

if config_env() == :prod and System.get_env("RELEASE_NAME") != nil do
  config :grabakey, Grabakey.Repo,
    database: System.get_env("GAK_DATABASE_PATH") || raise("Missing GAK_DATABASE_PATH"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  config :grabakey,
    server_port: String.to_integer(port),
    mailer_config: [
      enabled: true,
      baseurl: "grabakey.org",
      adapter: Swoosh.Adapters.AmazonSES,
      region: System.get_env("GAK_AWSSES_REGION") || raise("Missing GAK_AWSSES_REGION"),
      access_key: System.get_env("GAK_AWSSES_ACCESSKEY") || raise("Missing GAK_AWSSES_ACCESSKEY"),
      secret: System.get_env("GAK_AWSSES_SECRET") || raise("Missing GAK_AWSSES_SECRET")
    ]
end
