defmodule Grabakey.WebServerTest do
  use Grabakey.DataCase, async: false

  @email "test@grabakey.org"

  defp build_headers(opts \\ []) do
    length = Keyword.get(opts, :length, 0)
    token = Keyword.get(opts, :token)

    %{
      "Accept" => "text/plain",
      "Content-Type" => "text/plain",
      "Content-Length" => "#{length}"
    }
    |> Map.merge(if token != nil, do: %{"Gak-Token" => "#{token}"}, else: %{})
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
    headers = build_headers(length: String.length(@email))
    stream_ref = :gun.post(conn_pid, '/api/users', headers, @email)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}
    user = UserDb.find_by_email(@email)
    assert nil != user.id
    user = UserDb.find_by_id(user.id)
    assert @email == user.email
    assert :ok == :gun.shutdown(conn_pid)
    assert :ok == WebServer.stop()
  end

  test "recreate user api test" do
    WebServer.start_link()
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, user0} = UserDb.create_from_email(@email)
    headers = build_headers(length: String.length(@email))
    stream_ref = :gun.post(conn_pid, '/api/users', headers, @email)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}
    user = UserDb.find_by_email(@email)
    assert nil != user.id
    user = UserDb.find_by_id(user.id)
    assert @email == user.email
    assert user0.id == user.id
    assert user0.token != user.token
    assert :ok == :gun.shutdown(conn_pid)
    assert :ok == WebServer.stop()
  end

  test "delete user api test" do
    WebServer.start_link()
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, user} = UserDb.create_from_email(@email)
    headers = build_headers(token: user.token)
    stream_ref = :gun.delete(conn_pid, '/api/users/#{user.id}', headers)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}
    assert nil == UserDb.find_by_email(@email)
    assert :ok == :gun.shutdown(conn_pid)
    assert :ok == WebServer.stop()
  end

  test "update user pubkey api test" do
    WebServer.start_link()
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, user} = UserDb.create_from_email(@email)
    headers = build_headers(token: user.token)
    stream_ref = :gun.put(conn_pid, '/api/users/#{user.id}', headers, "UPDATED")
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}
    user2 = UserDb.find_by_email(@email)
    assert "UPDATED" == user2.pubkey
    assert user.token != user2.token
    assert :ok == :gun.shutdown(conn_pid)
    assert :ok == WebServer.stop()
  end

  test "get user pubkey api test" do
    WebServer.start_link()
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, user} = UserDb.create_from_email(@email)
    headers = build_headers()
    stream_ref = :gun.get(conn_pid, '/api/users/#{user.id}', headers)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}
    {:ok, body} = :gun.await_body(conn_pid, stream_ref)
    assert "PUBKEY" == body
    assert :ok == :gun.shutdown(conn_pid)
    assert :ok == WebServer.stop()
  end
end
