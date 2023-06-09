defmodule Grabakey.Repo do
  use Ecto.Repo,
    otp_app: :grabakey,
    adapter: Ecto.Adapters.SQLite3
end
