defmodule Grabakey.WebServerTest do
  use ExUnit.Case
  use Grabakey.WebServerTestHelper

  test "server test" do
    WebServer.start_link()
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, _, _}
    stream_ref = :gun.get(conn_pid, '/fs/test')
    assert_receive {:gun_response, _, _, _, _, _}
    {:ok, body} = :gun.await_body(conn_pid, stream_ref)
    assert body == "/fs/test"
    assert :ok == :gun.shutdown(conn_pid)
    assert :ok == WebServer.stop()
  end
end
