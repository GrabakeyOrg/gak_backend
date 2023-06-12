privkey = File.read!(".secrets/private.pem")

dkim_opts = [
  {:s, "dkim"},
  {:d, "grabakey.org"},
  {:private_key, {:pem_plain, privkey}}
]

signed_mail_body =
  :mimemail.encode(
    {"text", "plain",
     [
       {"Subject", "DKIM testing"},
       {"From", "Test <test@grabakey.org>"},
       {"To", "Hello <hello@grabakey.org>"}
     ], %{}, "This is the email body"},
    dkim: dkim_opts
  )
  |> IO.inspect()

# The outgoing SMTP server, smtp.gmail.com, supports TLS.
# If your client begins with plain text, before issuing the STARTTLS command,
# use port 465 (for SSL), or port 587 (for TLS)
# Works only from grabakey.org vps through ssh tunnel
# brew install sshuttle
# sshuttle -r grabakey.org 0.0.0.0/0
# [local sudo] Password:
# c : Connected to server.
:gen_smtp_client.send_blocking(
  {
    "test@grabakey.org",
    ["hello@grabakey.org"],
    signed_mail_body
  },
  relay: "grabakey.org",
  trace_fun: &:io.format/2
)
|> IO.inspect()
