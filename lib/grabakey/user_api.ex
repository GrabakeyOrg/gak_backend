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

  def from_text(req, :new = state) do
    len = :cowboy_req.body_length(req)

    if is_integer(len) and len <= @max_email_len do
      {:ok, body, req} = :cowboy_req.read_body(req)
      # FIXME validate email format
      {:ok, _id} = UserDb.create(body)
      # FIXME send email with id+token
      # 204 no content
      {true, req, state}
    else
      # 400 bad request
      {false, req, state}
    end
  end
end
