ARG ALPINE_VERSION=3.10

FROM elixir:1.9.2-alpine AS builder

ARG APP_NAME=watchdog_bot
ARG APP_VSN=0.1.0
ARG MIX_ENV=prod

# ENV TG_TOK=
# ENV PG_DB=
# ENV PG_USER=
# ENV PG_PASS=
# ENV PG_HOST=
ENV PG_PORT=5432
ENV RELX_REPLACE_OS_VARS=true

WORKDIR /opt/app

RUN apk update && \
  apk upgrade --no-cache && \
  mix local.rebar --force && \
  mix local.hex --force

# This copies our app source code into the build container
COPY . .

RUN mix do deps.get, deps.compile, compile


# Cmpile the app
RUN \
  mkdir -p /opt/built && \
  mix distillery.release --verbose && \
  cp _build/${MIX_ENV}/rel/${APP_NAME}/releases/${APP_VSN}/${APP_NAME}.tar.gz /opt/built && \
  cd /opt/built && \
  tar -xzf ${APP_NAME}.tar.gz && \
  rm ${APP_NAME}.tar.gz


# New image, which will be used in production
FROM alpine:${ALPINE_VERSION}

ARG APP_NAME=watchdog_bot

# Install dependencies
RUN apk update && \
    apk add --no-cache \
      docker \
      bash \
      openssl-dev

ENV REPLACE_OS_VARS=true \
    APP_NAME=${APP_NAME}


WORKDIR /opt/app

COPY --from=builder /opt/built .

CMD trap 'exit' INT; /opt/app/bin/${APP_NAME} foreground
