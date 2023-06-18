defmodule Grabakey.WebServerTest do
  use Grabakey.DataCase, async: false

  @email "test@grabakey.org"
  @pubkey1 "ssh-ed25519 PUBKEY nobody@localhost"
  @pubkey2 "ssh-ed25519 UPDATED nobody@localhost"
  @toms 4000

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
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    stream_ref = :gun.get(conn_pid, '/api/ping')
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    {:ok, body} = :gun.await_body(conn_pid, stream_ref)
    assert body == "pong"
    assert :ok == :gun.shutdown(conn_pid)
  end

  test "create pubkey api test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    headers = build_headers(length: String.length(@email))
    stream_ref = :gun.post(conn_pid, '/api/pubkey', headers, @email)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    pubkey = PubkeyDb.find_by_email(@email)
    assert nil != pubkey || pubkey.id
    pubkey = PubkeyDb.find_by_id(pubkey.id)
    assert @email == pubkey.email
    assert :ok == :gun.shutdown(conn_pid)
  end

  test "recreate pubkey api test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, pubkey0} = PubkeyDb.create_from_email(@email)
    headers = build_headers(length: String.length(@email))
    stream_ref = :gun.post(conn_pid, '/api/pubkey', headers, @email)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    pubkey = PubkeyDb.find_by_email(@email)
    assert nil != pubkey || pubkey.id
    pubkey = PubkeyDb.find_by_id(pubkey.id)
    assert @email == pubkey.email
    assert pubkey0.id == pubkey.id
    assert pubkey0.token != pubkey.token
    assert pubkey0.updated_at != pubkey.updated_at
    assert pubkey0.inserted_at == pubkey.inserted_at
    assert :ok == :gun.shutdown(conn_pid)
  end

  test "delete pubkey api test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, pubkey} = PubkeyDb.create_from_email(@email)
    headers = build_headers(token: pubkey.token)
    stream_ref = :gun.delete(conn_pid, '/api/pubkey/#{pubkey.id}', headers)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    assert nil == PubkeyDb.find_by_email(@email)
    assert :ok == :gun.shutdown(conn_pid)
  end

  test "update pubkey pubkey api test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, pubkey} = PubkeyDb.create_from_email(@email)
    headers = build_headers(token: pubkey.token)
    stream_ref = :gun.put(conn_pid, '/api/pubkey/#{pubkey.id}', headers, @pubkey2)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    pubkey2 = PubkeyDb.find_by_email(@email)
    assert @pubkey2 == pubkey2.data
    assert pubkey.token != pubkey2.token
    assert :ok == :gun.shutdown(conn_pid)
  end

  test "get pubkey pubkey api test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, pubkey} = PubkeyDb.create_from_email(@email)
    headers = build_headers()
    stream_ref = :gun.get(conn_pid, '/api/pubkey/#{pubkey.id}', headers)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    {:ok, body} = :gun.await_body(conn_pid, stream_ref)
    assert @pubkey1 == body
    assert :ok == :gun.shutdown(conn_pid)
  end
end
