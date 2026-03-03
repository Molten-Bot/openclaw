FROM node:lts-trixie-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

ENV OPENCLAW_VERSION=2026.3.1

# Install openclaw globally
RUN npm install -g openclaw@${OPENCLAW_VERSION}
