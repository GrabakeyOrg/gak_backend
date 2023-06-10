defmodule Grabakey.Mailer do
  use GenServer
  import Swoosh.Email

  @mailer "mailer@grabakey.org"

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    config = Keyword.get(opts, :config, [])
    {:ok, config}
  end

  def handle_call({:deliver, user, token}, _from, config) do
    enabled = Keyword.get(config, :enabled, false)
    result = deliver(enabled, config, user, token)
    {:reply, result, config}
  end

  def deliver(user, token) do
    GenServer.call(__MODULE__, {:deliver, user, token})
  end

  def deliver(true, config, user, token) do
    adapter = Keyword.fetch!(config, :adapter)
    baseurl = Keyword.fetch!(config, :baseurl)

    new()
    |> to(user.email)
    |> from({"Grabakey Mailer", @mailer})
    |> subject("Grabakey token and next steps")
    |> html_body(body(user.id, user.email, token, baseurl))
    |> adapter.deliver(config)
  end

  def deliver(_enabled, _config, _user, _token) do
    {:ok, :disabled}
  end

  defp body(id, email, token, baseurl) do
    """
    You just ran:<br/>
    <br/>
    <b>curl #{baseurl}/api/users -X POST -d #{email}</b><br/>
    <br/>
    With output:<br/>
    <br/>
    <b>UserID:</b> #{id}<br/>
    <b>Token:</b> #{token}<br/>
    <br/>
    Next possible steps are:<br/>
    <br/>
    # generate an ed25519 ssh key pair<br/>
    <b>ssh-keygen -t ed25519</b><br/>
    <br/>
    # upload your ed25519 public key (256 byte size limit)<br/>
    <b>curl #{baseurl}/api/users/#{id} -X PUT -H "Gak-Token: #{token}" -d @$HOME/.ssh/id_ed25519.pub</b><br/>
    <br/>
    # show your current pubkey<br/>
    <b>curl -w "\\n" #{baseurl}/api/users/#{id}</b><br/>
    <br/>
    # delete your account<br/>
    <b>curl #{baseurl}/api/users/#{id} -X DELETE -H "Gak-Token: #{token}"</b><br/>
    """
  end
end
