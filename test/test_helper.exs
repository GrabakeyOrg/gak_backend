ExUnit.start()

defmodule Grabakey.TestHelper do
  defmacro __using__(_) do
    quote do
      alias Grabakey.WebServer
      alias Grabakey.UserDb
    end
  end
end
