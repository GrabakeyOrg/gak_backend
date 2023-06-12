defmodule Grabakey.Mailer do
  @mailer "mailer@grabakey.org"

  def deliver(user, token, config) do
    enabled = Keyword.get(config, :enabled, false)

    if enabled do
      send(config, user, token)
    else
      {:ok, :disabled}
    end
  end

  def send(config, user, token) do
    privkey = Keyword.fetch!(config, :privkey)
    baseurl = Keyword.fetch!(config, :baseurl)
    template = Keyword.fetch!(config, :template)

    bindings = [
      id: user.id,
      token: token,
      baseurl: baseurl,
      email: user.email
    ]

    {body, _bindings} = Code.eval_quoted(template, bindings)

    dkim_opts = [
      {:s, "dkim"},
      {:d, "grabakey.org"},
      {:private_key, {:pem_plain, privkey}}
    ]

    signed_mail_body =
      :mimemail.encode(
        {"text", "html",
         [
           {"Subject", "Grabakey token and next steps"},
           {"From", "Grabakey Mailer <#{@mailer}>"},
           {"To", user.email}
         ], %{}, body},
        dkim: dkim_opts
      )

    [_, domain] = String.split(user.email, "@")

    result =
      :gen_smtp_client.send_blocking(
        {
          @mailer,
          [user.email],
          signed_mail_body
        },
        relay: domain,
        trace_fun: &:io.format/2
      )

    # {:error, :retries_exceeded, {:network_failure, 'alt4.gmr-smtp-in.l.google.com', {:error, :econnrefused}}}
    case result do
      mail_id when is_binary(mail_id) -> {:ok, mail_id}
      error -> error
    end
  end
end
