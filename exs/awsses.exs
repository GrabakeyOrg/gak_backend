import Swoosh.Email

config =
  [
    region: System.get_env("GAK_AWSSES_REGION"),
    access_key: System.get_env("GAK_AWSSES_ACCESSKEY"),
    secret: System.get_env("GAK_AWSSES_SECRET")
  ]
  |> IO.inspect()

new()
|> to("samuel@grabakey.org")
|> from({"Hello", "hello@grabakey.org"})
|> subject("Mailer Script")
|> text_body("This is a test email.")
|> Swoosh.Adapters.AmazonSES.deliver(config)
|> IO.inspect()
