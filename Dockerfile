FROM node:lts-trixie-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

ARG OPENCLAW_VERSION
ENV OPENCLAW_VERSION=${OPENCLAW_VERSION}

# Install openclaw globally
RUN npm install -g openclaw@${OPENCLAW_VERSION}
