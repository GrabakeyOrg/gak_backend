defmodule Grabakey.WebServer do
  @doc """
  see https://ninenines.eu/docs/en/cowboy/2.6/manual/

  Returns {:ok, listener_pid} | {:error, reason}.
  """
  def start_link(opts \\ []) do
    # name can be any erlang term
    port = Keyword.get(opts, :port, 0)
    name = Keyword.get(opts, :name, __MODULE__)

    dispatch =
      :cowboy_router.compile([
        {:_,
         [
           {'/fs/:path', __MODULE__, :state}
         ]}
      ])

    trans_opts = [port: port]
    proto_opts = %{env: %{dispatch: dispatch}}
    :cowboy.start_clear(name, trans_opts, proto_opts)
  end

  @doc """
  Returns :ok.
  """
  def stop(name \\ __MODULE__) do
    :cowboy.stop_listener(name)
  end

  @doc """
  Returns the TCP port number.
  """
  def get_port(name \\ __MODULE__) do
    :ranch.get_port(name)
  end

  def init(req, state) do
    path = :cowboy_req.binding(:path, req)

    req =
      :cowboy_req.reply(
        200,
        %{"content-type" => "text/plain"},
        "/fs/#{path}",
        req
      )

    {:ok, req, state}
  end

  def terminate(_reason, _partial_req, _state) do
    :ok
  end
end
