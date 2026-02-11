# distroless-image

## Overview
- Repository for building and publishing distroless base images.
- Build definitions are managed by `docker-bake.hcl` and `Makefile`.
- Dockerfiles are organized under `dockerfiles/`.

## Tech Stack
- Docker Buildx Bake (`docker buildx bake`)
- Multi-stage Dockerfiles based on `gcr.io/distroless/base-debian13`
- GitHub Actions workflow for manual publish (`workflow_dispatch`)

## Managed Images
Build targets from `docker-bake.hcl`:
- `distroless-base-apache24`
- `distroless-base-movabletype`
- `distroless-base-nginx`
- `distroless-base-wordpress-cli`
- `distroless-base-wordpress-php83`
- `distroless-base-wordpress-php84`
- `distroless-base-wordpress-php85`

Tag format:
- `${NAMESPACE}/distroless-base:<variant>-${TAG}`
- Example: `your-namespace/distroless-base:apache24-latest`

## Configuration
Main variables (`Makefile`, `.env.example`):
- `DOCKERHUB_NAMESPACE` (default namespace source)
- `NAMESPACE` (defaults to `DOCKERHUB_NAMESPACE`, or `local`)
- `TAG` (default: `latest`)
- `PLATFORMS` (default: `linux/amd64,linux/arm64`)
- `TIME_ZONE` (default: `Asia/Tokyo`)
- `WP_VERSION` (default: `latest`)

## Key Paths
- `docker-bake.hcl`
- `Makefile`
- `.env.example`
- `.github/workflows/dockerhub-publish.yml`
- `dockerfiles/apache24/Dockerfile`
- `dockerfiles/movabletype/Dockerfile`
- `dockerfiles/nginx/Dockerfile`
- `dockerfiles/wordpress/cli/Dockerfile`
- `dockerfiles/wordpress/php83/Dockerfile`
- `dockerfiles/wordpress/php84/Dockerfile`
- `dockerfiles/wordpress/php85/Dockerfile`

## Local Development
1. Prepare environment variables:
```bash
cp .env.example .env
```

2. Check available Make targets:
```bash
make help
```

3. List available bake targets:
```bash
make list
```

4. Show resolved configuration:
```bash
make config
```

5. Build one image locally:
```bash
make build IMAGE=distroless-base-nginx TAG=latest
```

6. Build all images locally:
```bash
make build-all TAG=latest
```

7. Push one image:
```bash
make login
make push IMAGE=distroless-base-nginx TAG=latest
```

8. Push all images:
```bash
make login
make push-all TAG=latest
```

## GitHub Actions
Manual publish is defined in `.github/workflows/dockerhub-publish.yml` (`workflow_dispatch`).

Inputs:
- `target` (`all` or a single bake target)
- `tag`
- `platforms`
- `time_zone`
- `wp_version`

Required secrets:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## Notes
- `dockerfiles/movabletype/Dockerfile` builds a runtime image that does not bundle Movable Type source code.
