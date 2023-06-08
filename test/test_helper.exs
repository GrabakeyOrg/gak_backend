ExUnit.start()

defmodule Grabakey.WebServerTestHelper do
  defmacro __using__(_) do
    quote do
      alias Grabakey.WebServer
    end
  end
end
