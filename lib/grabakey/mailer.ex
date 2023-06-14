defmodule Grabakey.Mailer do
  @mailer "mailer@grabakey.org"
  @replyto "hello@grabakey.org"

  def send_create(config, pubkey, token) do
    enabled = Keyword.get(config, :enabled, false)

    if enabled do
      {body, _bindings} = eval_template(config, :create, %{pubkey | token: token})
      send_sync_mxdns(config, pubkey.email, "Pubkey #{pubkey.id} next steps", body)
    else
      {:ok, :disabled}
    end
  end

  def send_update(config, pubkey) do
    enabled = Keyword.get(config, :enabled, false)

    if enabled do
      {body, _bindings} = eval_template(config, :update, pubkey)
      send_sync_mxdns(config, pubkey.email, "Pubkey #{pubkey.id} next steps", body)
    else
      {:ok, :disabled}
    end
  end

  def send_delete(config, pubkey) do
    enabled = Keyword.get(config, :enabled, false)

    if enabled do
      {body, _bindings} = eval_template(config, :delete, pubkey)
      send_sync_mxdns(config, pubkey.email, "Pubkey #{pubkey.id} next steps", body)
    else
      {:ok, :disabled}
    end
  end

  def eval_template(config, template, pubkey) do
    baseurl = Keyword.fetch!(config, :baseurl)
    quoted = Keyword.fetch!(config, template)

    bindings = [
      baseurl: baseurl,
      token: pubkey.token,
      email: pubkey.email,
      data: pubkey.data,
      id: pubkey.id
    ]

    Code.eval_quoted(quoted, bindings)
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
           {"From", "Grabakey <#{@mailer}>"},
           {"Reply-To", "Grabakey <#{@replyto}>"},
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
