# Grabakey Backend

MVP

- phoenix + sqlite
- single key per-user
- email authentication
- curl as client
- ed25519 only
- AuthorizedKeysCommand plugin
- User: id (uuid), email, pubkey, verified (email), token

Use Cases

- Create user: 
  - email -> id=new, token=new and send to email 
  - new 5m token created and sent every time
- Verify email: email + token -> verified=true 
- Update pubkey: id + pubkey + token -> pubkey=updated
- Install sshd plugin
- Purge cron
  - Unused tokens

API

- POST /api/users <- email -> id+token
- GET /api/users/:id -> pubkey
- PUT /api/users/:id <- token+pubkey
- DELETE /api/users/:id <- token

## Howto

```bash
mix new backend --module Grabakey --app grabakey --sup
cd phoenix
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
