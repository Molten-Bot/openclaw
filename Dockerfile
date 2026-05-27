FROM node:lts-trixie-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY OPENCLAW_VERSION /tmp/OPENCLAW_VERSION

# Install openclaw globally, and backfill Control UI assets if upstream npm
# package omitted dist/control-ui for this version.
RUN set -eux; \
    OPENCLAW_VERSION="$(tr -d '[:space:]' < /tmp/OPENCLAW_VERSION)"; \
    npm install -g "openclaw@${OPENCLAW_VERSION}"; \
    OPENCLAW_ROOT="$(npm root -g)/openclaw"; \
    CONTROL_UI_INDEX="${OPENCLAW_ROOT}/dist/control-ui/index.html"; \
    if [ ! -f "${CONTROL_UI_INDEX}" ]; then \
      echo "Control UI assets missing in openclaw@${OPENCLAW_VERSION}; building from source tag."; \
      corepack enable; \
      corepack prepare pnpm@10.23.0 --activate; \
      rm -rf /tmp/openclaw-src; \
      if ! git clone --depth 1 --branch "v${OPENCLAW_VERSION}" https://github.com/openclaw/openclaw.git /tmp/openclaw-src; then \
        git clone --depth 1 --branch "v${OPENCLAW_VERSION}-1" https://github.com/openclaw/openclaw.git /tmp/openclaw-src; \
      fi; \
      cd /tmp/openclaw-src; \
      CI=true pnpm --dir ui install --prod=false; \
      pnpm --dir ui build; \
      mkdir -p "${OPENCLAW_ROOT}/dist"; \
      rm -rf "${OPENCLAW_ROOT}/dist/control-ui"; \
      cp -R dist/control-ui "${OPENCLAW_ROOT}/dist/control-ui"; \
      test -f "${CONTROL_UI_INDEX}"; \
      rm -rf /tmp/openclaw-src /root/.local/share/pnpm /root/.cache/pnpm /root/.cache/node/corepack; \
    fi
