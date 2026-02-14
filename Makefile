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
LOCAL_TAG_WITH_ARCH ?= 1

BAKE_ENV = NAMESPACE=$(NAMESPACE) TAG=$(TAG)

TRIVY_OUT_DIR ?= /tmp/trivy-distroless-compare

TRIVY_COMPARE_IMAGES = \
	httpd:2.4-alpine \
	distroless-mt:httpd \
	nginx:1.29-alpine-slim \
	distroless-wp:nginx \
	perl:5.40-slim \
	distroless-mt:movabletype \
	wordpress:php8.4-fpm-alpine \
	distroless-wp:wordpress-php84

.PHONY: help list config login build build-all push push-all trivy-pull trivy-scan trivy-summary trivy-compare

help: ## Show this help
	@grep -h -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-16s %s\n", $$1, $$2}'

list: ## Show build targets from docker-bake.hcl
	@docker buildx bake --file $(BAKE_FILE) --list targets

config: ## Show resolved variables
	@echo "DOCKERHUB_NAMESPACE=$(DOCKERHUB_NAMESPACE)"
	@echo "NAMESPACE=$(NAMESPACE)"
	@echo "TAG=$(TAG)"
	@echo "PLATFORMS=$(PLATFORMS)"
	@echo "LOCAL_TAG_WITH_ARCH=$(LOCAL_TAG_WITH_ARCH)"
	@echo "BAKE_FILE=$(BAKE_FILE)"
	@echo "TRIVY_OUT_DIR=$(TRIVY_OUT_DIR)"

login: ## Login to Docker Hub
	@docker login

build: ## Build one image locally (IMAGE=nginx)
	@if [ -z "$(IMAGE)" ]; then \
		echo "IMAGE is required. Example: make build IMAGE=nginx"; \
		exit 1; \
	fi
	@if ! $(BAKE_ENV) docker buildx bake --file $(BAKE_FILE) --print "$(IMAGE)" >/dev/null 2>&1; then \
		echo "Unknown IMAGE: $(IMAGE)"; \
		echo "Run: make list"; \
		exit 1; \
	fi
	@platforms=$$(printf '%s\n' "$(PLATFORMS)" | tr ',' ' '); \
	count=$$(printf '%s\n' "$$platforms" | wc -w | tr -d ' '); \
	for platform in $$platforms; do \
		arch=$${platform##*/}; \
		tag="$(TAG)"; \
		if [ "$$count" -gt 1 ] && [ "$(LOCAL_TAG_WITH_ARCH)" = "1" ]; then \
			tag="$(TAG)-$$arch"; \
		fi; \
		echo "Building $(IMAGE) for $$platform (TAG=$$tag)"; \
		NAMESPACE=$(NAMESPACE) TAG=$$tag docker buildx bake --file $(BAKE_FILE) $(IMAGE) --load --set "$(IMAGE).platform=$$platform"; \
	done

build-all: ## Build all images locally
	@platforms=$$(printf '%s\n' "$(PLATFORMS)" | tr ',' ' '); \
	count=$$(printf '%s\n' "$$platforms" | wc -w | tr -d ' '); \
	for platform in $$platforms; do \
		arch=$${platform##*/}; \
		tag="$(TAG)"; \
		if [ "$$count" -gt 1 ] && [ "$(LOCAL_TAG_WITH_ARCH)" = "1" ]; then \
			tag="$(TAG)-$$arch"; \
		fi; \
		echo "Building all for $$platform (TAG=$$tag)"; \
		NAMESPACE=$(NAMESPACE) TAG=$$tag docker buildx bake --file $(BAKE_FILE) all --load --set "*.platform=$$platform"; \
	done

push: ## Push one image to Docker Hub (IMAGE=nginx)
	@if [ -z "$(IMAGE)" ]; then \
		echo "IMAGE is required. Example: make push IMAGE=nginx"; \
		exit 1; \
	fi
	@if ! $(BAKE_ENV) docker buildx bake --file $(BAKE_FILE) --print "$(IMAGE)" >/dev/null 2>&1; then \
		echo "Unknown IMAGE: $(IMAGE)"; \
		echo "Run: make list"; \
		exit 1; \
	fi
	@if [ "$(NAMESPACE)" = "local" ]; then \
		echo "NAMESPACE is 'local'. Set DOCKERHUB_NAMESPACE or NAMESPACE before push."; \
		echo "Example: DOCKERHUB_NAMESPACE=your-username $(MAKE) push IMAGE=$(IMAGE)"; \
		exit 1; \
	fi
	@$(BAKE_ENV) docker buildx bake --file $(BAKE_FILE) $(IMAGE) --push --set "$(IMAGE).platform=$(PLATFORMS)"

push-all: ## Push all images to Docker Hub
	@if [ "$(NAMESPACE)" = "local" ]; then \
		echo "NAMESPACE is 'local'. Set DOCKERHUB_NAMESPACE or NAMESPACE before push."; \
		echo "Example: DOCKERHUB_NAMESPACE=your-username $(MAKE) push-all"; \
		exit 1; \
	fi
	@$(BAKE_ENV) docker buildx bake --file $(BAKE_FILE) all --push --set "*.platform=$(PLATFORMS)"

trivy-pull: ## Pull builder images used in Trivy comparison
	@docker pull httpd:2.4-alpine
	@docker pull nginx:1.29.0-alpine-slim
	@docker pull perl:5.42-slim
	@docker pull wordpress:php8.4-fpm-alpine

trivy-scan: ## Scan builder/final image pairs and save raw JSON
	@mkdir -p "$(TRIVY_OUT_DIR)"
	@for img in $(TRIVY_COMPARE_IMAGES); do \
		fname=$$(echo "$$img" | sed 's#[/:]#_#g'); \
		echo "Scanning $$img"; \
		trivy image --scanners vuln --format json --quiet "$$img" > "$(TRIVY_OUT_DIR)/$$fname.json"; \
	done
	@trivy --version > "$(TRIVY_OUT_DIR)/trivy-version.txt"
	@echo "saved to: $(TRIVY_OUT_DIR)"

trivy-summary: ## Print severity summary table from saved Trivy JSON
	@printf 'IMAGE\tTOTAL\tCRITICAL\tHIGH\tMEDIUM\tLOW\tUNKNOWN\n'
	@for img in $(TRIVY_COMPARE_IMAGES); do \
		fname=$$(echo "$$img" | sed 's#[/:]#_#g'); \
		file="$(TRIVY_OUT_DIR)/$$fname.json"; \
		total=$$(jq '[.Results[]?.Vulnerabilities[]?] | length' "$$file"); \
		critical=$$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' "$$file"); \
		high=$$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="HIGH")] | length' "$$file"); \
		medium=$$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="MEDIUM")] | length' "$$file"); \
		low=$$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="LOW")] | length' "$$file"); \
		unknown=$$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="UNKNOWN")] | length' "$$file"); \
		printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$$img" "$$total" "$$critical" "$$high" "$$medium" "$$low" "$$unknown"; \
	done

trivy-compare: trivy-scan trivy-summary ## Run scan and print summary
