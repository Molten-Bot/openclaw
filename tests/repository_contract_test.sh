#!/bin/sh
set -eu

failures=0

fail() {
  printf 'not ok - %s\n' "$1"
  failures=$((failures + 1))
}

pass() {
  printf 'ok - %s\n' "$1"
}

assert_file_contains() {
  file=$1
  pattern=$2
  description=$3

  if grep -Fq -- "$pattern" "$file"; then
    pass "$description"
  else
    fail "$description"
    printf '  missing pattern in %s: %s\n' "$file" "$pattern"
  fi
}

assert_file_matches() {
  file=$1
  pattern=$2
  description=$3

  if grep -Eq -- "$pattern" "$file"; then
    pass "$description"
  else
    fail "$description"
    printf '  missing regex in %s: %s\n' "$file" "$pattern"
  fi
}

assert_workflow_block_contains() {
  block_start=$1
  pattern=$2
  description=$3

  if awk -v start="$block_start" -v pattern="$pattern" '
    $0 ~ start { in_block = 1 }
    in_block && index($0, pattern) { found = 1 }
    in_block && /^  [a-zA-Z0-9_-]+:/ && $0 !~ start { exit }
    END { exit found ? 0 : 1 }
  ' .github/workflows/docker-release.yml; then
    pass "$description"
  else
    fail "$description"
    printf '  missing pattern after %s: %s\n' "$block_start" "$pattern"
  fi
}

version=$(tr -d '[:space:]' < OPENCLAW_VERSION)
case "$version" in
  *[!0-9.]* | "" | .* | *.)
    fail "OPENCLAW_VERSION uses dotted numeric version"
    printf '  found: %s\n' "$version"
    ;;
  *.*.*)
    pass "OPENCLAW_VERSION uses dotted numeric version"
    ;;
  *)
    fail "OPENCLAW_VERSION uses dotted numeric version"
    printf '  found: %s\n' "$version"
    ;;
esac

for dockerfile in Dockerfile Dockerfile.alpine; do
  assert_file_contains "$dockerfile" 'COPY OPENCLAW_VERSION /tmp/OPENCLAW_VERSION' "$dockerfile copies shared version file"
  assert_file_contains "$dockerfile" 'OPENCLAW_VERSION="$(tr -d '\''[:space:]'\'' < /tmp/OPENCLAW_VERSION)"' "$dockerfile trims version whitespace"
  assert_file_contains "$dockerfile" 'npm install -g "openclaw@${OPENCLAW_VERSION}"' "$dockerfile installs selected openclaw version"
  assert_file_contains "$dockerfile" 'CONTROL_UI_INDEX="${OPENCLAW_ROOT}/dist/control-ui/index.html"' "$dockerfile defines Control UI index path"
  assert_file_contains "$dockerfile" 'if [ ! -f "${CONTROL_UI_INDEX}" ]; then' "$dockerfile has missing Control UI fallback branch"
  assert_file_contains "$dockerfile" 'corepack prepare pnpm@10.23.0 --activate' "$dockerfile pins pnpm used for fallback build"
  assert_file_contains "$dockerfile" 'git clone --depth 1 --branch "v${OPENCLAW_VERSION}"' "$dockerfile first tries exact upstream tag"
  assert_file_contains "$dockerfile" 'git clone --depth 1 --branch "v${OPENCLAW_VERSION}-1"' "$dockerfile falls back to patched upstream tag"
  assert_file_contains "$dockerfile" 'CI=true pnpm --dir ui install --prod=false' "$dockerfile installs UI build dependencies"
  assert_file_contains "$dockerfile" 'pnpm --dir ui build' "$dockerfile builds Control UI assets"
  assert_file_contains "$dockerfile" 'cp -R dist/control-ui "${OPENCLAW_ROOT}/dist/control-ui"' "$dockerfile copies fallback Control UI assets"
  assert_file_contains "$dockerfile" 'test -f "${CONTROL_UI_INDEX}"' "$dockerfile verifies fallback asset exists"
done

assert_file_contains Dockerfile 'FROM node:lts-trixie-slim AS builder' "Debian image uses Node LTS slim base"
assert_file_contains Dockerfile 'apt-get install -y \' "Debian image installs OS dependencies"
assert_file_contains Dockerfile 'git \' "Debian image installs git"
assert_file_contains Dockerfile 'rm -rf /var/lib/apt/lists/*' "Debian image clears apt lists"

assert_file_contains Dockerfile.alpine 'FROM node:lts-alpine AS builder' "Alpine image uses Node LTS Alpine base"
assert_file_contains Dockerfile.alpine 'apk add --no-cache \' "Alpine image installs OS dependencies without cache"
assert_file_contains Dockerfile.alpine 'git \' "Alpine image installs git"
assert_file_contains Dockerfile.alpine 'make \' "Alpine image installs make"
assert_file_contains Dockerfile.alpine 'g++ \' "Alpine image installs C++ toolchain"
assert_file_contains Dockerfile.alpine 'cmake \' "Alpine image installs cmake"
assert_file_contains Dockerfile.alpine 'linux-headers' "Alpine image installs linux headers"

assert_file_contains .github/workflows/docker-release.yml "branches:" "Workflow declares branch triggers"
assert_file_contains .github/workflows/docker-release.yml "- main" "Workflow targets main branch"
assert_file_contains .github/workflows/docker-release.yml "'v*'" "Workflow publishes v-prefixed tags"
assert_file_contains .github/workflows/docker-release.yml "'Dockerfile'" "Workflow watches Debian Dockerfile"
assert_file_contains .github/workflows/docker-release.yml "'Dockerfile.alpine'" "Workflow watches Alpine Dockerfile"
assert_file_contains .github/workflows/docker-release.yml "'OPENCLAW_VERSION'" "Workflow watches version file"
assert_file_contains .github/workflows/docker-release.yml "cancel-in-progress: true" "Workflow cancels older runs for same ref"
assert_file_contains .github/workflows/docker-release.yml "docker/setup-qemu-action@v3" "Workflow prepares QEMU for multi-arch builds"
assert_file_contains .github/workflows/docker-release.yml "docker/setup-buildx-action@v3" "Workflow prepares Buildx"
assert_file_contains .github/workflows/docker-release.yml 'VERSION=$(tr -d '\''[:space:]'\'' < OPENCLAW_VERSION)' "Workflow reads trimmed openclaw version"
assert_file_contains .github/workflows/docker-release.yml 'if [ -z "$VERSION" ]; then' "Workflow rejects empty openclaw version"
assert_file_contains .github/workflows/docker-release.yml "secrets.DOCKERHUB_TOKEN is required." "Publish job validates Docker Hub token"
assert_file_contains .github/workflows/docker-release.yml "docker/login-action@v3" "Publish job logs in to Docker Hub"
assert_file_contains .github/workflows/docker-release.yml "push: false" "Pull request validation does not push images"
assert_file_contains .github/workflows/docker-release.yml "push: true" "Publish job pushes images"

assert_file_matches .github/workflows/docker-release.yml 'variant: debian' "Workflow matrix includes Debian variant"
assert_file_matches .github/workflows/docker-release.yml 'dockerfile: Dockerfile$' "Workflow matrix maps Debian variant to Dockerfile"
assert_file_matches .github/workflows/docker-release.yml 'platforms: linux/amd64,linux/arm64' "Workflow matrix builds Debian multi-arch"
assert_file_matches .github/workflows/docker-release.yml 'variant: alpine' "Workflow matrix includes Alpine variant"
assert_file_matches .github/workflows/docker-release.yml 'dockerfile: Dockerfile\.alpine' "Workflow matrix maps Alpine variant to Dockerfile.alpine"
assert_file_matches .github/workflows/docker-release.yml 'platforms: linux/amd64$' "Workflow matrix keeps Alpine amd64-only"

assert_workflow_block_contains '^  validate:' "github.event_name == 'pull_request'" "Validation job only runs for pull requests"
assert_workflow_block_contains '^  build-and-push:' "github.ref == 'refs/heads/main'" "Publish job runs on main"
assert_workflow_block_contains '^  build-and-push:' "startsWith(github.ref, 'refs/tags/v')" "Publish job runs on version tags"

assert_file_contains .github/workflows/docker-release.yml '"${IMAGE}:latest"' "Main Debian publish includes latest tag"
assert_file_contains .github/workflows/docker-release.yml '"${IMAGE}:lts"' "Main Debian publish includes lts tag"
assert_file_contains .github/workflows/docker-release.yml '"${IMAGE}:${VERSION}"' "Main Debian publish includes version tag"
assert_file_contains .github/workflows/docker-release.yml '"${IMAGE}:${VERSION}-lts"' "Main Debian publish includes version-lts tag"
assert_file_contains .github/workflows/docker-release.yml '"${IMAGE}:alpine"' "Main Alpine publish includes alpine tag"
assert_file_contains .github/workflows/docker-release.yml '"${IMAGE}:${VERSION}-alpine"' "Main Alpine publish includes version-alpine tag"
assert_file_contains .github/workflows/docker-release.yml '"${IMAGE}:${RAW_TAG}"' "Version-tag Debian publish includes raw v tag"
assert_file_contains .github/workflows/docker-release.yml '"${IMAGE}:${STRIPPED_TAG}"' "Version-tag Debian publish includes stripped tag"
assert_file_contains .github/workflows/docker-release.yml '"${IMAGE}:${RAW_TAG}-alpine"' "Version-tag Alpine publish includes raw alpine tag"
assert_file_contains .github/workflows/docker-release.yml '"${IMAGE}:${STRIPPED_TAG}-alpine"' "Version-tag Alpine publish includes stripped alpine tag"

if [ "$failures" -eq 0 ]; then
  printf 'All repository contract tests passed.\n'
else
  printf '%s repository contract test(s) failed.\n' "$failures"
  exit 1
fi
