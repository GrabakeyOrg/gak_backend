defmodule Grabakey.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = Application.fetch_env!(:grabakey, :server_port)
    config = Application.fetch_env!(:grabakey, :mailer_config)
    delay = Application.fetch_env!(:grabakey, :dos_delay)

    # Starts a worker by calling: Grabakey.Worker.start_link(arg)
    # {Grabakey.Worker, arg}
    children = [
      Grabakey.Repo,
      {Grabakey.Mailer, config: config},
      {Grabakey.WebServer, port: port, delay: delay}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Grabakey.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
