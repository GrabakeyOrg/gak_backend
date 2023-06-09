# Grabakey Backend

MVP

- cowboy + sqlite
- single key per-user
- email authentication
- curl as client
- ed25519 only
- AuthorizedKeysCommand plugin
- User: id (uuid), email, pubkey, token

Use Cases

- Create user: 
  - email -> id=new, token=new and send to email 
  - new token created and sent every time
- Update pubkey: id + pubkey + token -> pubkey=updated, token=new
- Install sshd plugin
- Purge cron
  - Account with default pubkey after N hours

API

- POST /api/users <- email -> id+token
- DELETE /api/users/:id <- token
- PUT /api/users/:id <- token+pubkey
- GET /api/users/:id -> pubkey

## Todo

- App supervisor
- Email curl samples
- Purge cron job
- AWS release
- DOS delay

## Howto

```bash
mix new backend --module Grabakey --app grabakey --sup
mix ecto.gen.repo -r Grabakey.Repo
mix ecto.gen.migration create_users
cd phoenix
mix ecto.migrate
sqlite3 grabakey_test.db .schema users
sqlite3 grabakey_dev.db .schema users
```

## Future

- CDN
- 2FA
- CLI

## References

- https://github.com/woylie/ecto_ulid
- https://www.davekuhlman.org/cowboy-rest-add-get-update-list.html
- https://ninenines.eu/docs/en/cowboy/2.9/guide/rest_flowcharts/
- https://ninenines.eu/docs/en/gun/2.0/guide/
