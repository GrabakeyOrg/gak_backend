defmodule Grabakey.UserApi do
  alias Grabakey.UserDb

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

  # FIXME validate email format
  # FIXME send email with id+token
  def from_text(req, :new = state) do
    len = :cowboy_req.body_length(req)

    with {true, req} <- {is_integer(len), req},
         {true, req} <- {len <= @max_email_len, req},
         {{:ok, body, req}, _} <- {:cowboy_req.read_body(req), req},
         {{:ok, _user}, req} <- {UserDb.create_from_email(body), req} do
      # 204 no content
      {true, req, state}
    else
      # 400 bad request
      {_, req} -> {false, req, state}
    end
  end
end
