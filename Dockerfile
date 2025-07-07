FROM hexpm/elixir:1.18.3-erlang-27.1.3-ubuntu-focal-20250404

WORKDIR /app

RUN apt-get update && \
  apt-get install -y git && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && \
  mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./

RUN mix deps.get --only $MIX_ENV

RUN mkdir config

COPY config/config.exs config/$MIX_ENV.exs config/

RUN mix deps.compile

COPY lib lib
COPY priv priv

RUN mix compile

COPY config/runtime.exs config/

EXPOSE 4000

CMD ["mix", "phx.server"] 