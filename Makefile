.PHONY: all fmt vet test build build-image clean help

# Include generated Makefile targets
-include Makefile.infracode

GO ?= go

# ── Code quality ────────────────────────────────────────────────────────────

## fmt: Format all Go source files
fmt:
	@cd infracode && $(GO) fmt ./...

## vet: Run go vet
vet:
	@cd infracode && $(GO) vet ./...

## test: Run all tests
test:
	@cd infracode && $(GO) test ./...

## build: Build all Go packages
build:
	@cd infracode && $(GO) build ./...

## build-image: Build and push the Renovate worker image to the local registry
build-image:
	@$(MAKE) -C image build

## clean: Remove build artifacts and generated files
clean:
	@rm -rf .infracode/generated .infracode/index

all: fmt vet test build
