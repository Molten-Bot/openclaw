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

The main file to edit is the `Dockerfile`. Common changes include:
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

Once a PR is merged into `main`, the Docker image is automatically built and pushed as `moltenbot/openclaw:latest` via GitHub Actions.

To publish a versioned release, a maintainer will push a tag in the format `vYYYY.M.P` (e.g. `v2026.3.1`), which will push both `vYYYY.M.P` and `YYYY.M.P` tags to Docker Hub.

## License

[MIT](LICENSE)
