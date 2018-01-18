#Build Frontend
FROM node:alpine as node_builder

ENV NODE_ENV production
WORKDIR /app
ADD . .
RUN npm install
RUN npm run build

# Build Elixir
FROM elixir:slim as builder

RUN apt-get -qq update
RUN apt-get -qq install git build-essential

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

WORKDIR /app
ENV MIX_ENV prod
ADD . .
RUN mix deps.get
RUN mix release --env=$MIX_ENV

#RUN dat shit
FROM debian:jessie-slim

ENV MIX_ENV prod
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update
RUN apt-get -qq install -y locales

# Set LOCALE to UTF8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get -qq install libssl1.0.0 libssl-dev
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/bitmsg .
COPY --from=node_builder /app/dist ./dist

CMD ["./bin/bitmsg", "foreground"]