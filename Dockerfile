FROM node:lts-trixie-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY OPENCLAW_VERSION /tmp/OPENCLAW_VERSION
COPY scripts/install-openclaw.sh /usr/local/bin/install-openclaw

# Install openclaw globally, and backfill Control UI assets if upstream npm
# package omitted dist/control-ui for this version.
RUN sh /usr/local/bin/install-openclaw
