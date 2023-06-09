defmodule Grabakey.UserApi do
  alias Grabakey.UserDb
  alias Grabakey.Mailer

  @max_email_len 128

  def init(req, state) do
    {:cowboy_rest, req, state}
  end

  def allowed_methods(req, state) do
    {["GET", "POST", "PUT", "DELETE"], req, state}
  end

  def content_types_accepted(req, state) do
    {[{{"text", "plain", []}, :from_text}], req, state}
  end

  def content_types_provided(req, state) do
    {[{{"text", "plain", []}, :to_text}], req, state}
  end

  def to_text(req, state) do
    {"pong", req, state}
  end

  # FIXME send email with id+token
  def from_text(req, {:new, delay} = state) do
    # basic DOS defence
    :timer.sleep(delay)
    len = :cowboy_req.body_length(req)

    # find_by_email required to fetch the real id on conflict update
    # user.token to get the real updated token even if race condition
    with {true, req} <- {is_integer(len), req},
         {true, req} <- {len <= @max_email_len, req},
         {{:ok, body, req}, _} <- {:cowboy_req.read_body(req), req},
         {{:ok, user}, body, req} <- {UserDb.create_from_email(body), body, req},
         {user, token, req} <- {UserDb.find_by_email(body), user.token, req},
         {true, user, token, req} <- {user != nil, user, token, req},
         {{:ok, _res}, req} <- {Mailer.deliver(user, token), req} do
      # 204 no content
      {true, req, state}
    else
      # 400 bad request
      _res -> {false, req, state}
    end
  end
end
