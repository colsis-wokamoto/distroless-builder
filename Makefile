SHELL := /bin/sh

ifneq (,$(wildcard .env))
include .env
export
endif

BAKE_FILE ?= docker-bake.hcl

DOCKERHUB_NAMESPACE ?= local
NAMESPACE ?= $(DOCKERHUB_NAMESPACE)
TAG ?= latest
PLATFORMS ?= linux/amd64,linux/arm64
TIME_ZONE ?= Asia/Tokyo
WP_VERSION ?= latest

BAKE_ENV = NAMESPACE=$(NAMESPACE) TAG=$(TAG) TIME_ZONE=$(TIME_ZONE) WP_VERSION=$(WP_VERSION)

.PHONY: help list config login build build-all push push-all

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-16s %s\n", $$1, $$2}'

list: ## Show build targets from docker-bake.hcl
	@docker buildx bake --file $(BAKE_FILE) --list targets

config: ## Show resolved variables
	@echo "NAMESPACE=$(NAMESPACE)"
	@echo "TAG=$(TAG)"
	@echo "PLATFORMS=$(PLATFORMS)"
	@echo "TIME_ZONE=$(TIME_ZONE)"
	@echo "WP_VERSION=$(WP_VERSION)"

login: ## Login to Docker Hub
	@docker login

build: ## Build one image locally (IMAGE=distroless-base-nginx)
	@if [ -z "$(IMAGE)" ]; then \
		echo "IMAGE is required. Example: make build IMAGE=distroless-base-nginx"; \
		exit 1; \
	fi
	@if ! $(BAKE_ENV) docker buildx bake --file $(BAKE_FILE) --print "$(IMAGE)" >/dev/null 2>&1; then \
		echo "Unknown IMAGE: $(IMAGE)"; \
		echo "Run: make list"; \
		exit 1; \
	fi
	@$(BAKE_ENV) docker buildx bake --file $(BAKE_FILE) $(IMAGE) --load

build-all: ## Build all images locally
	@$(BAKE_ENV) docker buildx bake --file $(BAKE_FILE) all --load

push: ## Push one image to Docker Hub (IMAGE=distroless-base-nginx)
	@if [ -z "$(IMAGE)" ]; then \
		echo "IMAGE is required. Example: make push IMAGE=distroless-base-nginx"; \
		exit 1; \
	fi
	@if ! $(BAKE_ENV) docker buildx bake --file $(BAKE_FILE) --print "$(IMAGE)" >/dev/null 2>&1; then \
		echo "Unknown IMAGE: $(IMAGE)"; \
		echo "Run: make list"; \
		exit 1; \
	fi
	@if [ "$(NAMESPACE)" = "local" ]; then \
		echo "NAMESPACE is 'local'. Set DOCKERHUB_NAMESPACE or NAMESPACE before push."; \
		exit 1; \
	fi
	@$(BAKE_ENV) docker buildx bake --file $(BAKE_FILE) $(IMAGE) --push --set "$(IMAGE).platform=$(PLATFORMS)"

push-all: ## Push all images to Docker Hub
	@if [ "$(NAMESPACE)" = "local" ]; then \
		echo "NAMESPACE is 'local'. Set DOCKERHUB_NAMESPACE or NAMESPACE before push."; \
		exit 1; \
	fi
	@$(BAKE_ENV) docker buildx bake --file $(BAKE_FILE) all --push --set "*.platform=$(PLATFORMS)"
