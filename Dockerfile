# =============================================================================
# Build stage
# =============================================================================
ARG ELIXIR_VERSION=1.17.3
ARG OTP_VERSION=27.1.2
ARG ALPINE_VERSION=3.20.3

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION}"
ARG RUNNER_IMAGE="alpine:${ALPINE_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

# Install build dependencies (includes sqlite-dev for ecto_sqlite3)
RUN apk add --no-cache build-base git nodejs npm sqlite-dev

WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV="prod"

# Fetch and compile dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

RUN mkdir config

# Copy compile-time config files (runtime.exs is loaded at runtime, not here)
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Build assets
COPY priv priv
COPY assets assets
RUN mix assets.deploy

# Compile the application
COPY lib lib
RUN mix compile

# Copy runtime config last — changes here do not require recompiling
COPY config/runtime.exs config/

# Build the release
RUN mix release

# =============================================================================
# Runtime stage
# =============================================================================
FROM ${RUNNER_IMAGE} AS app

# Install runtime dependencies for Erlang + SQLite
RUN apk add --no-cache libgcc libstdc++ ncurses-libs sqlite-libs

WORKDIR /app

RUN chown nobody:nobody /app

# Create the directory for the SQLite database (mounted as a volume)
RUN mkdir -p /data && chown nobody:nobody /data

USER nobody:nobody

COPY --from=builder --chown=nobody:nobody /app/_build/prod/rel/zip_liner ./

ENV HOME=/app
ENV MIX_ENV=prod
ENV PHX_HOST=localhost
ENV PORT=4000
ENV DATABASE_PATH=/data/zipliner_prod.db

# Persist the SQLite database across container restarts
VOLUME ["/data"]

EXPOSE 4000

COPY --chown=nobody:nobody entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
