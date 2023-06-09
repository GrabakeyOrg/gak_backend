import Config

port =
  case config_env() do
    :test -> "0"
    _ -> "31601"
  end

port = System.get_env("GAK_SERVER_PORT", port)

config :grabakey,
  server_port: String.to_integer(port),
  mailer_config: [
    baseurl: "localhost:#{port}",
    adapter: Swoosh.Adapters.AmazonSES,
    enabled: System.get_env("GAK_AWSSES_ENABLED", "false") |> String.to_atom(),
    region: System.get_env("GAK_AWSSES_REGION"),
    access_key: System.get_env("GAK_AWSSES_ACCESSKEY"),
    secret: System.get_env("GAK_AWSSES_SECRET")
  ],
  ecto_repos: [Grabakey.Repo],
  generators: [binary_id: true]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
