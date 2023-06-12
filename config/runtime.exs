import Config

if config_env() == :prod and System.get_env("RELEASE_NAME") != nil do
  privkey = System.get_env("GAK_PRIVKEY_PATH") || raise("Missing GAK_PRIVKEY_PATH")
  port = System.get_env("GAK_SERVER_PORT", "31681")

  config :grabakey, Grabakey.Repo,
    database: System.get_env("GAK_DATABASE_PATH") || raise("Missing GAK_DATABASE_PATH"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  config :grabakey,
    server_port: String.to_integer(port),
    mailer_config: [
      baseurl: "https://grabakey.org",
      privkey: File.read!(privkey),
      enabled: System.get_env("GAK_MAILER_ENABLED", "false") |> String.to_atom()
    ]
end
