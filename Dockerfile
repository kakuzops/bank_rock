FROM elixir:1.12.2
RUN apt-get update && \
    apt-get install -f -y postgresql-client && \
    apt-get install -y build-essential make

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install hex package manager
RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get \
    && mix compile \
    && MIX_ENV=prod mix release

EXPOSE 4000
CMD ["_build/prod/rel/bank_rock/bin/bank_rock", "start"]