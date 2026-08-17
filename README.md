# renovate-deployment

Owns the custom Renovate worker image and the production deployment for the
home cluster's Renovate instance. This replaces the hand-maintained
`gitops-hermetic/system/renovate/` path in the configs repo.

The worker image extends `ghcr.io/renovatebot/renovate` with the Go toolchain,
make, and git so Renovate's `postUpgradeTasks` can run `make generate` in the
repositories it updates and commit the regenerated infracode artifacts into the
same PR.

## Layout

- `image/` — Dockerfile + Makefile for the worker image.
- `deploy/` — committed Kubernetes manifests (namespace, config secret, CronJob).
  Synced by the `renovate` Argo CD Application against path `deploy/`.
- `infracode/` — hand-written manifest that renders this repo's generated files
  (`Makefile.infracode`, `.drone.yml`, `renovate.json`, `.infracode/` outputs).
  This repo dogfoods the `renovate` domain.

## Building the worker image

```sh
make build           # from image/, or:
cd image && make build
```

Builds and pushes `registry.local.rothwell.us/devilmonastery/renovate-worker:<tag>`
via the remote BuildKit daemon (`BUILDER=remote`). `make build-local` builds
without pushing.

Tag convention: `<base-version>-worker-<n>`, e.g. `44.32.2-worker-2`. Bump
`WORKER_BUILD` (or the `TAG` variable) when the Dockerfile's pinned inputs
change, then update the image reference in `deploy/renovate-manifests.yaml` in
the same PR.

Pinned inputs are the Dockerfile ARGs (`RENOVATE_BASE` via the Renovate pin,
`GO_VERSION` + `GO_SHA256`). Change them deliberately; Renovate proposes base
image bumps, which should be merged only after re-pinning and re-releasing the
worker tag.

## Deployment

The `renovate` Argo CD Application points at this repo, path `deploy/`,
namespace `renovate`. The CronJob runs daily at 02:00 UTC.

## Secrets (do not commit)

- `renovate-github-token` (key `token`) in the `renovate` namespace holds the
  GitHub PAT. It is applied out-of-band and is deliberately NOT in this repo.
  Never commit a token here.
- `renovate-config` is committed as a regular Secret (config is not secret).

## CI

`.drone.yml` (generated) runs Go checks, `make generate-verify`, and a
BuildKit build+push of the worker image on push to `main` and on PRs.
