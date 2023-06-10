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

Errors

- curl -v localhost:31601/api/usersX -X POST -d user@grabakey.org
  - 404 not found
- curl -v localhost:31601/api/users/X -X DELETE
- curl -v localhost:31601/api/users -X POST
  - 400 bad request (failed validation)
  - 500 internal error (on exception)
- curl -v localhost:31601/api/users -X DELETE
  - 500 internal error (on :stop)

```bash
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
iex -S mix
curl -v localhost:31601/api/users -X POST -d user@grabakey.org
sqlite3 grabakey_dev.db "select * from users"
curl -v localhost:31601/api/users/01H2H215K5A56YBNKVE3E008ST
curl -v localhost:31601/api/users/01H2H215K5A56YBNKVE3E008ST -X PUT -H "Gak-Token: 01H2H215K5JXZ7HFMT8EA96RHY" -d "UPDATED"
curl -v localhost:31601/api/users/01H2H215K5A56YBNKVE3E008ST -X PUT -H "Gak-Token: 01H2H215K5JXZ7HFMT8EA96RHY" -d @$HOME/.ssh/id_ed25519.pub
curl -v localhost:31601/api/users/01H2H215K5A56YBNKVE3E008ST -X DELETE -H "Gak-Token: 01H2H1WV7SMEJR4E19HY7S0J38"
```

## Todo

- Entry module
- Cache headers
- Purge cron job
- SPF softfail
- AWS release

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
