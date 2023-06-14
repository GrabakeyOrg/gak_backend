defmodule Grabakey.PubkeyApi do
  alias Grabakey.PubkeyDb
  alias Grabakey.Mailer

  @max_body_len 256
  @token_header "gak-token"
  @headers %{"content-type" => "text/plain"}
  @fail_delay 1000

  def init(req, {:new, _} = state) do
    method = :cowboy_req.method(req)
    dos_delay(method, state)

    case method do
      "POST" ->
        create_pubkey(req, state)

      _ ->
        fail_delay()
        req = :cowboy_req.reply(404, req)
        {:ok, req, state}
    end
  end

  def init(req, {:id, _} = state) do
    method = :cowboy_req.method(req)
    dos_delay(method, state)

    case method do
      "GET" ->
        get_pubkey(req, state)

      "PUT" ->
        update_pubkey(req, state)

      "DELETE" ->
        delete_pubkey(req, state)

      _ ->
        fail_delay()
        req = :cowboy_req.reply(404, req)
        {:ok, req, state}
    end
  end

  def create_pubkey(req, {_, %{mailer: mailer}} = state) do
    len = :cowboy_req.body_length(req)

    # find_by_email required to fetch the real id on conflict update
    # pubkey.token to get the real updated token even if race condition
    with {true, req} <- {is_integer(len), req},
         {true, req} <- {len > 3 and len <= @max_body_len, req},
         {{:ok, email, req}, _} <- {:cowboy_req.read_body(req), req},
         {{:ok, pubkey}, email, req} <- {PubkeyDb.create_from_email(email), email, req},
         {pubkey, token, req} <- {PubkeyDb.find_by_email(email), pubkey.token, req},
         {true, pubkey, token, req} <- {pubkey != nil, pubkey, token, req},
         {{:ok, _res}, req} <- {Mailer.send_create(mailer, pubkey, token), req} do
      req = :cowboy_req.reply(200, @headers, req)
      {:ok, req, state}
    else
      _res ->
        fail_delay()
        req = :cowboy_req.reply(400, req)
        {:ok, req, state}
    end
  end

  def delete_pubkey(req, {_, %{mailer: mailer}} = state) do
    id = :cowboy_req.binding(:id, req)
    token = :cowboy_req.header(@token_header, req)

    with {true, req} <- {is_binary(token), req},
         {{:ok, _}, req} <- {Ecto.ULID.cast(id), req},
         {{:ok, _}, req} <- {Ecto.ULID.cast(token), req},
         {pubkey, req} <- {PubkeyDb.find_by_id_and_token(id, token), req},
         {true, pubkey, req} <- {pubkey != nil, pubkey, req},
         {{:ok, _res}, req} <- {PubkeyDb.delete(pubkey), req},
         {{:ok, _res}, req} <- {Mailer.send_delete(mailer, pubkey), req} do
      req = :cowboy_req.reply(200, @headers, req)
      {:ok, req, state}
    else
      _res ->
        fail_delay()
        req = :cowboy_req.reply(400, req)
        {:ok, req, state}
    end
  end

  def update_pubkey(req, {_, %{mailer: mailer}} = state) do
    len = :cowboy_req.body_length(req)
    id = :cowboy_req.binding(:id, req)
    token = :cowboy_req.header(@token_header, req)

    with {true, req} <- {is_binary(token), req},
         {{:ok, _}, req} <- {Ecto.ULID.cast(id), req},
         {{:ok, _}, req} <- {Ecto.ULID.cast(token), req},
         {true, req} <- {is_integer(len), req},
         {true, req} <- {len > 0 and len <= @max_body_len, req},
         {{:ok, data, req}, _} <- {:cowboy_req.read_body(req), req},
         {true, data, req} <- {valid_pubkey?(data), data, req},
         {pubkey, req} <- {PubkeyDb.find_by_id_and_token(id, token), req},
         {true, pubkey, req} <- {pubkey != nil, pubkey, req},
         {{:ok, pubkey}, req} <- {PubkeyDb.update_pubkey(pubkey, data), req},
         {{:ok, _res}, req} <- {Mailer.send_update(mailer, pubkey), req} do
      req = :cowboy_req.reply(200, @headers, req)
      {:ok, req, state}
    else
      _res ->
        fail_delay()
        req = :cowboy_req.reply(400, req)
        {:ok, req, state}
    end
  end

  def get_pubkey(req, state) do
    id = :cowboy_req.binding(:id, req)

    with {{:ok, _}, req} <- {Ecto.ULID.cast(id), req},
         {pubkey, req} <- {PubkeyDb.find_by_id(id), req},
         {true, pubkey, req} <- {pubkey != nil, pubkey, req} do
      req = :cowboy_req.reply(200, @headers, pubkey.data, req)
      {:ok, req, state}
    else
      _res ->
        fail_delay()
        req = :cowboy_req.reply(400, req)
        {:ok, req, state}
    end
  end

  defp dos_delay(method, {_, %{delay: delay}}) do
    case method do
      "PUT" -> :timer.sleep(delay)
      "POST" -> :timer.sleep(delay)
      "DELETE" -> :timer.sleep(delay)
      "GET" -> :nop
    end
  end

  defp fail_delay() do
    :timer.sleep(@fail_delay)
  end

  defp valid_pubkey?(data) do
    case String.split(data, " ") do
      ["ssh-ed25519", _, _] -> true
      _ -> false
    end
  end
end
