defmodule Grabakey.Mailer do
  @mailer "mailer@grabakey.org"

  def deliver(config, pubkey, token) do
    enabled = Keyword.get(config, :enabled, false)

    if enabled do
      eval_and_send(config, pubkey, token)
    else
      {:ok, :disabled}
    end
  end

  def eval_and_send(config, pubkey, token) do
    baseurl = Keyword.fetch!(config, :baseurl)
    template = Keyword.fetch!(config, :template)

    bindings = [
      id: pubkey.id,
      token: token,
      baseurl: baseurl,
      email: pubkey.email
    ]

    {body, _bindings} = Code.eval_quoted(template, bindings)

    send_sync_mxdns(config, pubkey.email, "Grabakey ID and next steps", body)
  end

  def send_sync_mxdns(config, to, subject, body) do
    privkey = Keyword.fetch!(config, :privkey)

    dkim_opts = [
      {:s, "dkim"},
      {:d, "grabakey.org"},
      {:private_key, {:pem_plain, privkey}}
    ]

    # default encoding utf-8 if iconv is present
    signed_mail_body =
      :mimemail.encode(
        {"text", "html",
         [
           {"Subject", subject},
           {"From", "Grabakey Mailer <#{@mailer}>"},
           {"To", to}
         ], %{content_type_params: [{"charset", "utf-8"}]}, body},
        dkim: dkim_opts
      )

    [_, domain] = String.split(to, "@")

    send_opts = [
      tls: :always,
      relay: domain,
      hostname: "grabakey.org",
      tls_options: [
        verify: :verify_peer,
        depth: 99,
        cacerts: :certifi.cacerts(),
        customize_hostname_check: [
          match_fun: fn _, _ -> true end
        ]
      ]
    ]

    result =
      :gen_smtp_client.send_blocking(
        {
          @mailer,
          [to],
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
