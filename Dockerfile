FROM node:lts-trixie-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY OPENCLAW_VERSION /tmp/OPENCLAW_VERSION
COPY patches /tmp/openclaw-patches

# Install openclaw globally, and rebuild Control UI assets when local patches
# are present or when upstream npm omitted dist/control-ui for this version.
RUN set -eux; \
    OPENCLAW_VERSION="$(tr -d '[:space:]' < /tmp/OPENCLAW_VERSION)"; \
    npm install -g "openclaw@${OPENCLAW_VERSION}"; \
    OPENCLAW_ROOT="$(npm root -g)/openclaw"; \
    CONTROL_UI_INDEX="${OPENCLAW_ROOT}/dist/control-ui/index.html"; \
    CONTROL_UI_PATCH="/tmp/openclaw-patches/openclaw-control-ui-dictation.patch"; \
    if [ -f "${CONTROL_UI_PATCH}" ] || [ ! -f "${CONTROL_UI_INDEX}" ]; then \
      echo "Building Control UI assets from source tag."; \
      corepack enable; \
      corepack prepare pnpm@10.23.0 --activate; \
      rm -rf /tmp/openclaw-src; \
      if ! git clone --depth 1 --branch "v${OPENCLAW_VERSION}" https://github.com/openclaw/openclaw.git /tmp/openclaw-src; then \
        git clone --depth 1 --branch "v${OPENCLAW_VERSION}-1" https://github.com/openclaw/openclaw.git /tmp/openclaw-src; \
      fi; \
      cd /tmp/openclaw-src; \
      if [ -f "${CONTROL_UI_PATCH}" ]; then git apply "${CONTROL_UI_PATCH}"; fi; \
      CI=true pnpm --dir ui install --prod=false; \
      pnpm --dir ui build; \
      mkdir -p "${OPENCLAW_ROOT}/dist"; \
      rm -rf "${OPENCLAW_ROOT}/dist/control-ui"; \
      cp -R dist/control-ui "${OPENCLAW_ROOT}/dist/control-ui"; \
      test -f "${CONTROL_UI_INDEX}"; \
      rm -rf /tmp/openclaw-src /root/.local/share/pnpm /root/.cache/pnpm /root/.cache/node/corepack; \
    fi
