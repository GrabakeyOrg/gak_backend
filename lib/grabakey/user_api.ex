defmodule Grabakey.UserApi do
  alias Grabakey.UserDb
  alias Grabakey.Mailer

  @max_body_len 128
  @token_header "gak-token"
  @headers %{"content-type" => "text/plain"}

  def init(req, :new = state) do
    method = :cowboy_req.method(req)
    dos_delay(state, method)

    case method do
      "POST" -> create_user(req, state)
      _ -> {:stop, req, state}
    end
  end

  def init(req, :id = state) do
    method = :cowboy_req.method(req)
    dos_delay(state, method)

    case method do
      "GET" -> get_pubkey(req, state)
      "PUT" -> update_pubkey(req, state)
      "DELETE" -> delete_user(req, state)
      _ -> {:stop, req, state}
    end
  end

  def create_user(req, state) do
    len = :cowboy_req.body_length(req)

    # find_by_email required to fetch the real id on conflict update
    # user.token to get the real updated token even if race condition
    with {true, req} <- {is_integer(len), req},
         {true, req} <- {len <= @max_body_len, req},
         {{:ok, email, req}, _} <- {:cowboy_req.read_body(req), req},
         {{:ok, user}, email, req} <- {UserDb.create_from_email(email), email, req},
         {user, token, req} <- {UserDb.find_by_email(email), user.token, req},
         {true, user, token, req} <- {user != nil, user, token, req},
         {{:ok, _res}, req} <- {Mailer.deliver(user, token), req} do
      req = :cowboy_req.reply(200, @headers, req)
      {:ok, req, state}
    else
      _res -> {:stop, req, state}
    end
  end

  def delete_user(req, state) do
    id = :cowboy_req.binding(:id, req)
    token = :cowboy_req.header(@token_header, req)

    with {true, req} <- {is_binary(token), req},
         {user, req} <- {UserDb.find_by_id_and_token(id, token), req},
         {true, user, req} <- {user != nil, user, req},
         {{:ok, _res}, req} <- {UserDb.delete(user), req} do
      req = :cowboy_req.reply(200, @headers, req)
      {:ok, req, state}
    else
      _res -> {:stop, req, state}
    end
  end

  def update_pubkey(req, state) do
    len = :cowboy_req.body_length(req)
    id = :cowboy_req.binding(:id, req)
    token = :cowboy_req.header(@token_header, req)

    with {true, req} <- {is_integer(len), req},
         {true, req} <- {len <= @max_body_len, req},
         {{:ok, pubkey, req}, _} <- {:cowboy_req.read_body(req), req},
         {user, req} <- {UserDb.find_by_id_and_token(id, token), req},
         {true, user, req} <- {user != nil, user, req},
         {{:ok, _res}, req} <- {UserDb.update_pubkey(user, pubkey), req} do
      req = :cowboy_req.reply(200, @headers, req)
      {:ok, req, state}
    else
      _res -> {:stop, req, state}
    end
  end

  def get_pubkey(req, state) do
    id = :cowboy_req.binding(:id, req)

    with {user, req} <- {UserDb.find_by_id(id), req},
         {true, user, req} <- {user != nil, user, req} do
      req = :cowboy_req.reply(200, @headers, user.pubkey, req)
      {:ok, req, state}
    else
      _res -> {:stop, req, state}
    end
  end

  # FIXME basic DOS defence
  defp dos_delay(_state, _method) do
    :timer.sleep(0)
  end
end
