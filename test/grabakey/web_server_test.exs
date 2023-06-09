defmodule Grabakey.WebServerTest do
  use Grabakey.DataCase, async: false

  @email "test@grabakey.org"

  defp text_headers(length) do
    %{
      "Accept" => "text/plain",
      "Content-Type" => "text/plain",
      "Content-Length" => "#{length}"
    }
  end

  test "web server ping test" do
    WebServer.start_link()
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    stream_ref = :gun.get(conn_pid, '/api/ping')
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}
    {:ok, body} = :gun.await_body(conn_pid, stream_ref)
    assert body == "pong"
    assert :ok == :gun.shutdown(conn_pid)
    assert :ok == WebServer.stop()
  end

  test "create user api test" do
    WebServer.start_link()
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    headers = String.length(@email) |> text_headers()
    stream_ref = :gun.post(conn_pid, '/api/users', headers, @email)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 204, _}
    user = UserDb.find_by_email(@email)
    assert nil != user.id
    user = UserDb.find_by_id(user.id)
    assert @email == user.email
    assert :ok == :gun.shutdown(conn_pid)
    assert :ok == WebServer.stop()
  end
end
