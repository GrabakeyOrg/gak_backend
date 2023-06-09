defmodule Grabakey.Mailer do
  import Swoosh.Email

  def deliver(user, token) do
    if System.get_env("GAK_AWSSES_ENABLED") == "true" do
      new()
      |> to(user.email)
      |> from({"Grabakey Mailer", "mailer@grabakey.org"})
      |> subject("This is your new Grabakey Token")
      |> text_body("UserID: #{user.id}\nToken: #{token}\n")
      |> Swoosh.Adapters.AmazonSES.deliver(config())
    else
      {:ok, :disabled}
    end
  end

  defp config() do
    [
      region: System.get_env("GAK_AWSSES_REGION"),
      access_key: System.get_env("GAK_AWSSES_ACCESSKEY"),
      secret: System.get_env("GAK_AWSSES_SECRET")
    ]
  end
end
