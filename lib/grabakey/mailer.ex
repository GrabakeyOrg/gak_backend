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
    hostname = Keyword.get(config, :hostname)

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

    send_opts = [
      tls: :always,
      relay: domain,
      tls_options: [
        verify: :verify_peer,
        depth: 99,
        cacerts: :certifi.cacerts(),
        customize_hostname_check: [
          match_fun: fn _, _ -> true end
        ]
      ]
    ]

    send_opts =
      case hostname do
        nil -> send_opts
        _ -> send_opts ++ [hostname: hostname]
      end

    result =
      :gen_smtp_client.send_blocking(
        {
          @mailer,
          [user.email],
          signed_mail_body
        },
        send_opts
      )

    # {:error, :retries_exceeded, {:network_failure, 'alt4.gmr-smtp-in.l.google.com', {:error, :econnrefused}}}
    case result do
      mail_id when is_binary(mail_id) -> {:ok, mail_id}
      error -> error
    end
  end
end
