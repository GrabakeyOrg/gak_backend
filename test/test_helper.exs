ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Grabakey.Repo, :manual)

defmodule Grabakey.TestHelper do
  defmacro __using__(_) do
    quote do
      alias Grabakey.WebServer
      alias Grabakey.UserDb
    end
  end
end
