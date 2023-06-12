defmodule Grabakey.Application do
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    port = Application.fetch_env!(:grabakey, :server_port)
    delay = Application.fetch_env!(:grabakey, :dos_delay)
    mailer = Application.fetch_env!(:grabakey, :mailer_config)
    database = Application.fetch_env!(:grabakey, Grabakey.Repo)[:database]
    Logger.info("Port #{port}")
    Logger.info("Db #{database}")

    children = [
      Grabakey.Repo,
      Grabakey.Migrator,
      {Grabakey.WebServer, port: port, delay: delay, mailer: mailer}
    ]

    opts = [strategy: :one_for_one, name: Grabakey.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
