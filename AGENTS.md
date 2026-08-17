# renovate-deployment agent guidance

## Purpose

This repo owns the Renovate worker image and the production deployment
manifests for the home cluster Renovate CronJob. It is itself an infracode
consumer and dogfoods the `renovate` domain (its `renovate.json` is generated).

## Boundaries

- Hand-written inputs: `infracode/manifest.go`, `image/Dockerfile`,
  `image/Makefile`, `deploy/*.yaml`, `go.mod`, README/AGENTS.
- Generated (DO NOT EDIT): `Makefile.infracode`, `.drone.yml`, `renovate.json`,
  everything under `.infracode/`.
- No secrets in this repo. The `renovate-github-token` Secret is applied
  out-of-band; only its consumption is declared in `deploy/`.

## Build and gates

```sh
make fmt vet test build generate generate-verify
```

Run from the repo root (via `Makefile.infracode` targets). `image/Makefile`
builds the worker image (`make -C image build`).

## Pinning rules

- The Renovate base image pin (`image/Dockerfile`, `RENOVATE_BASE` ARG marked
  with the `# renovate:` pinning comment) is the single base-image bump
  surface; Renovate PRs propose bumps.
- `deploy/renovate-manifests.yaml` image reference must match the
  `WORKER_BUILD` tag policy: when Dockerfile pinned inputs change, bump
  `WORKER_BUILD` in `image/Makefile` and the manifest image in one PR.
- Go version + sha256 pins live only in `image/Dockerfile` ARGs.

## Generation

`make generate` re-renders all generated files; `make generate-verify` fails on
drift between committed output and the manifest. After editing
`infracode/manifest.go`, always run generate before verify.

This repo's own Renovate `postUpgradeTasks` run `make generate` and commit the
regenerated artifacts after dependency bumps.
