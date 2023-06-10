FROM elixir:1.14.5-otp-25-alpine as release_stage

RUN apk add --no-cache build-base

RUN mix local.hex --force
RUN mix local.rebar --force

COPY mix.exs .
COPY mix.lock .
RUN mix deps.get

COPY lib ./lib
COPY test ./test
COPY priv ./priv
COPY config ./config

ENV MIX_ENV=prod
RUN mix release

FROM elixir:1.14.5-otp-25-alpine as run_stage

RUN apk add --no-cache sqlite
RUN apk add --no-cache curl
RUN apk add --no-cache netcat-openbsd

COPY --from=release_stage $HOME/_build .
RUN adduser -S -u 1001 -G root nonroot
RUN chown -R nonroot ./prod
USER nonroot
ENV GAK_DATABASE_PATH=/prod/grabakey_rel.db
CMD ["./prod/rel/grabakey/bin/grabakey", "start"]
