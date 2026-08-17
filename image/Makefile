# Reproducible build for the custom Renovate worker image (Go toolchain for
# postUpgradeTasks regeneration added to the official base).
#
# Usage:
#   make build          # build + push via remote BuildKit to the local registry
#   make build-local    # build with the local docker builder (no push)
#
# Pinned inputs live in the Dockerfile ARGs; override on the CLI if needed, e.g.
#   make build GO_VERSION=1.26.7 GO_SHA256=<64-hex>

REGISTRY ?= registry.local.rothwell.us/devilmonastery
IMAGE    ?= renovate-worker
RENOVATE_BASE_VERSION ?= 42.99.0
WORKER_BUILD ?= 1
TAG      ?= $(RENOVATE_BASE_VERSION)-worker-$(WORKER_BUILD)

GO_VERSION ?=
GO_SHA256  ?=
BUILDER    ?= remote
PLATFORM   ?= linux/amd64

BUILD_ARGS = \
  --build-arg RENOVATE_BASE=ghcr.io/renovatebot/renovate:$(RENOVATE_BASE_VERSION)
ifneq ($(GO_VERSION),)
BUILD_ARGS += \
  --build-arg GO_VERSION=$(GO_VERSION) \
  --build-arg GO_SHA256=$(GO_SHA256)
endif

.PHONY: build build-local

build:
	docker buildx build --builder $(BUILDER) --platform $(PLATFORM) \
	  $(BUILD_ARGS) \
	  -t $(REGISTRY)/$(IMAGE):$(TAG) --push .

build-local:
	docker build $(BUILD_ARGS) -t $(REGISTRY)/$(IMAGE):$(TAG) .
