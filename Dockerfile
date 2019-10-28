FROM elixir:1.9.2-alpine

MAINTAINER Yeboster <yeboster@gmail.com>

WORKDIR /usr/src/app/

# Install docker cli
RUN apk add git docker

# Copy projects file and build
COPY config ./config/
COPY lib ./lib/
COPY mix.exs .
COPY mix.lock .

# Get dependencies
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get 

# Compile production app
RUN MIX_ENV=prod mix release

CMD ./_build/prod/rel/watchdog_bot/bin/watchdog_bot start
