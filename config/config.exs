import Config

# Only bring here things that depend on the development or deploy environment
# Do not pollute with things that do not depend on config_env() or environ variables

# To send email from dev environ through grabakey.org server
# brew install sshuttle
# sshuttle -r grabakey.org 0.0.0.0/0
# [local sudo] Password:
# c : Connected to server.

delay =
  case config_env() do
    :test -> 0
    _ -> 1000
  end

port =
  case config_env() do
    :test -> "0"
    _ -> "31681"
  end

port = System.get_env("GAK_SERVER_PORT", port)

config :grabakey,
  dos_delay: delay,
  server_port: String.to_integer(port),
  mailer_config: [
    baseurl: "http://localhost:#{port}",
    privkey: File.read!(".secrets/private.pem"),
    create: EEx.compile_file("priv/templates/create.eex"),
    update: EEx.compile_file("priv/templates/update.eex"),
    delete: EEx.compile_file("priv/templates/delete.eex"),
    enabled: System.get_env("GAK_MAILER_ENABLED", "false") |> String.to_atom()
  ],
  ecto_repos: [Grabakey.Repo],
  generators: [binary_id: true]

config :grabakey, Grabakey.Repo, migration_timestamps: [type: :naive_datetime_usec]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
