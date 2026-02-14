# distroless-base-image

## Overview
- Repository for building Docker image artifacts used as distroless-oriented runtime bases.
- Build definitions are managed by `docker-bake.hcl` and `Makefile`.
- Dockerfiles are organized under `dockerfiles/` by runtime and version.
- `.env` is loaded automatically by `Makefile` when present.

## Tech Stack
- Docker Buildx Bake (`docker buildx bake`)
- GNU Make workflows for local build and push
- Multi-stage copy patterns for runtime binaries and dependent shared libraries
- Trivy + `jq` summary flow for vulnerability comparison (`make trivy-*` targets)

## Build Targets
Targets defined in `docker-bake.hcl`:
- `httpd` (`dockerfiles/httpd/24/Dockerfile`)
- `nginx` (`dockerfiles/nginx/latest/Dockerfile`)
- `nginx-stable` (`dockerfiles/nginx/stable/Dockerfile`)
- `php83` (`dockerfiles/php/83/Dockerfile`)
- `php84` (`dockerfiles/php/84/Dockerfile`)
- `php85` (`dockerfiles/php/85/Dockerfile`)
- `perl` (`dockerfiles/perl/54/Dockerfile`)
- `wp-cli` (`dockerfiles/wordpress/cli/Dockerfile`)

Tag patterns from `docker-bake.hcl` variables:
- `${NAMESPACE}/${PROJECT}-httpd:${TAG}`
- `${NAMESPACE}/${PROJECT}-nginx:${TAG}`
- `${NAMESPACE}/${PROJECT}-nginx:stable`
- `${NAMESPACE}/${PROJECT}-php8.3:${TAG}`
- `${NAMESPACE}/${PROJECT}-php8.4:${TAG}`
- `${NAMESPACE}/${PROJECT}-php8.5:${TAG}`
- `${NAMESPACE}/${PROJECT}-perl:${TAG}`
- `${NAMESPACE}/${PROJECT}-wp-cli:${TAG}`

## Configuration
Main variables (from `.env.example`, `Makefile`, and `docker-bake.hcl`):
- `DOCKERHUB_NAMESPACE` (default source namespace)
- `NAMESPACE` (defaults to `DOCKERHUB_NAMESPACE`; fallback is `local`)
- `PROJECT` (default: `distroless-builder`)
- `TAG` (default: `latest`)
- `PLATFORMS` (default: `linux/amd64,linux/arm64`)
- `LOCAL_TAG_WITH_ARCH` (default in `Makefile`: `1`)
- `BAKE_FILE` (default: `docker-bake.hcl`)
- `TRIVY_OUT_DIR` (default: `/tmp/trivy-distroless-compare`)

## Key Paths
- `docker-bake.hcl`
- `Makefile`
- `.env.example`
- `dockerfiles/httpd/24/Dockerfile`
- `dockerfiles/nginx/latest/Dockerfile`
- `dockerfiles/nginx/stable/Dockerfile`
- `dockerfiles/php/83/Dockerfile`
- `dockerfiles/php/84/Dockerfile`
- `dockerfiles/php/85/Dockerfile`
- `dockerfiles/perl/54/Dockerfile`
- `dockerfiles/perl/54/README-DBD-mysql.md`
- `dockerfiles/wordpress/cli/Dockerfile`

## Local Development
1. Create environment file:
```bash
cp .env.example .env
```

2. Confirm resolved values:
```bash
make config
```

3. Show available bake targets:
```bash
make list
```

4. Build one target locally:
```bash
make build IMAGE=nginx TAG=latest
```

5. Build all targets locally:
```bash
make build-all TAG=latest
```

6. Push one target:
```bash
make login
make push IMAGE=nginx TAG=latest
```

7. Push all targets:
```bash
make login
make push-all TAG=latest
```

For multi-platform local builds (`PLATFORMS` contains multiple values), `LOCAL_TAG_WITH_ARCH=1` appends architecture suffixes such as `-amd64` / `-arm64` during `--load` to avoid tag overwrite.

## Trivy Comparison Flow
1. Pull reference images:
```bash
make trivy-pull
```

2. Run scans and store raw JSON:
```bash
make trivy-scan
```

3. Print severity summary table:
```bash
make trivy-summary
```

Or run both scan and summary:
```bash
make trivy-compare
```

## Notes
- `make push` and `make push-all` fail intentionally when `NAMESPACE=local`.
- `dockerfiles/perl/54/README-DBD-mysql.md` documents why Oracle MySQL client libraries are used for `DBD::mysql` builds.
