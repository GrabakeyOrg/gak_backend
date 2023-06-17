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

  # how to avoid creation if emailing fails? transactions?
  def create_pubkey(req, {_, %{mailer: mailer}} = state) do
    len = :cowboy_req.body_length(req)

    # find_by_email required to fetch the real id on conflict update
    # pubkey.token to get the real updated token even if race condition
    with true <- is_integer(len),
         true <- len > 3 and len <= @max_body_len,
         {:ok, email, req} <- :cowboy_req.read_body(req),
         {:ok, pubkey} <- PubkeyDb.create_from_email(email),
         {pubkey, token} <- {PubkeyDb.find_by_email(email), pubkey.token},
         {true, pubkey} <- {pubkey != nil, pubkey},
         {:ok, _res} <- Mailer.send_create(mailer, %{pubkey | token: token}) do
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

    with true <- is_binary(token),
         {:ok, _} <- Ecto.ULID.cast(id),
         {:ok, _} <- Ecto.ULID.cast(token),
         pubkey <- PubkeyDb.find_by_id_and_token_5m(id, token),
         {true, pubkey} <- {pubkey != nil, pubkey},
         {:ok, _res} <- PubkeyDb.delete(pubkey),
         {:ok, _res} <- Mailer.send_delete(mailer, pubkey) do
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

    with true <- is_binary(token),
         {:ok, _} <- Ecto.ULID.cast(id),
         {:ok, _} <- Ecto.ULID.cast(token),
         true <- is_integer(len),
         true <- len > 0 and len <= @max_body_len,
         {:ok, data, req} <- :cowboy_req.read_body(req),
         true <- valid_pubkey?(data),
         pubkey <- PubkeyDb.find_by_id_and_token_5m(id, token),
         {true, pubkey} <- {pubkey != nil, pubkey},
         {:ok, pubkey} <- PubkeyDb.update_pubkey(pubkey, data),
         {:ok, _res} <- Mailer.send_update(mailer, pubkey) do
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

    with {:ok, _} <- Ecto.ULID.cast(id),
         pubkey <- PubkeyDb.find_by_id(id),
         {true, pubkey} <- {pubkey != nil, pubkey} do
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
