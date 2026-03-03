FROM node:lts-trixie-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY OPENCLAW_VERSION /tmp/OPENCLAW_VERSION

# Install openclaw globally
RUN npm install -g "openclaw@$(cat /tmp/OPENCLAW_VERSION)"
