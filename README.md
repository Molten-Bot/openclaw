# openclaw

Docker image for [openclaw](https://www.npmjs.com/package/openclaw), automatically built and published to [moltenbot/openclaw](https://hub.docker.com/r/moltenbot/openclaw) on Docker Hub.

Images are published as multi-arch manifests for:
- `linux/amd64`
- `linux/arm64`

[![Build & Push to Docker Hub](https://github.com/Molten-Bot/openclaw/actions/workflows/docker-release.yml/badge.svg)](https://github.com/Molten-Bot/openclaw/actions/workflows/docker-release.yml)

## Usage

```bash
docker pull moltenbot/openclaw:latest
```

### Tag Policy

| Tag | Base | Support level | Notes |
| --- | --- | --- | --- |
| `latest` | Debian slim (Node LTS) | Primary | Recommended default tag |
| `lts` | Debian slim (Node LTS) | Primary | Alias of `latest` |
| `alpine` | Alpine (Node LTS) | Best effort | Smaller image, may have musl compatibility differences |
| `${OPENCLAW_VERSION}` | Debian slim (Node LTS) | Primary | Versioned Debian image |
| `${OPENCLAW_VERSION}-lts` | Debian slim (Node LTS) | Primary | Versioned LTS alias |
| `${OPENCLAW_VERSION}-alpine` | Alpine (Node LTS) | Best effort | Versioned Alpine image |

Pull examples:

```bash
docker pull moltenbot/openclaw:latest
docker pull moltenbot/openclaw:lts
docker pull moltenbot/openclaw:alpine
```

Local builds automatically use the version in `OPENCLAW_VERSION`:

```bash
docker build -f Dockerfile .
docker build -f Dockerfile.alpine .
```

### Compatibility Notes

- Alpine images use musl instead of glibc.
- Native modules and some tooling may behave differently on Alpine.
- Debian LTS variants are the primary support target.
- Alpine is best-effort and may briefly lag if upstream breakage occurs.

### Migration Note

Prior behavior:
- `latest` tracked a current-major Debian Node image.

Current behavior:
- `latest` tracks Debian slim on Node LTS.

If you require a specific runtime behavior, pin explicit image tags.

## Contributing

Contributions are welcome! Please follow the steps below.

### 1. Fork & clone the repository

```bash
git clone https://github.com/Molten-Bot/openclaw.git
cd openclaw
```

### 2. Create a branch

Use a short, descriptive branch name:

```bash
git checkout -b your-feature-or-fix
```

### 3. Make your changes

The main files to edit are:
- `OPENCLAW_VERSION` (single source of truth for the openclaw npm version)
- `Dockerfile`
- `Dockerfile.alpine`

Common changes include:
- Bumping the `OPENCLAW_VERSION` to a newer npm release
- Changing the base Node.js image
- Adding extra tooling or configuration

### 4. Open a Pull Request

Push your branch and open a PR against `main`:

```bash
git push origin your-feature-or-fix
```

Then go to the repository on GitHub and click **"Compare & pull request"**.

Please include in your PR description:
- **What** changed and **why**
- Any relevant links (e.g. npm release notes for a version bump)

### 5. Versioning & releases

Once a PR is merged into `main`, GitHub Actions builds and pushes:
- Debian LTS tags: `latest`, `lts`, `${OPENCLAW_VERSION}`, `${OPENCLAW_VERSION}-lts`
- Alpine tags: `alpine`, `${OPENCLAW_VERSION}-alpine`

To publish a versioned release, a maintainer pushes a tag in the format `vYYYY.M.P` (e.g. `v2026.3.1`), which publishes:
- Debian: `vYYYY.M.P`, `YYYY.M.P`, `vYYYY.M.P-lts`, `YYYY.M.P-lts`
- Alpine: `vYYYY.M.P-alpine`, `YYYY.M.P-alpine`

## License

[MIT](LICENSE)
