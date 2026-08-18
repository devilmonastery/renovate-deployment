# renovate: pin Renovate base image
ARG RENOVATE_BASE=ghcr.io/renovatebot/renovate:44.33.2
FROM ${RENOVATE_BASE}

# Pinned inputs. Override on the CLI if needed, e.g.
#   make build GO_VERSION=1.26.7 GO_SHA256=<64-hex>
ARG GO_VERSION=1.26.6
ARG GO_SHA256=708effb774be8237570d0add163225abbdfaf4fca28b2611df167beba4feef89

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends make ca-certificates wget \
 && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /tmp/go.tgz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
 && echo "${GO_SHA256}  /tmp/go.tgz" | sha256sum -c - \
 && tar -C /usr/local -xzf /tmp/go.tgz \
 && rm /tmp/go.tgz

# Private Go modules are fetched with a token: insteadOf rewrites the SSH
# form of github.com URLs to HTTPS, and callers (Drone CI, the worker
# entrypoint wrapper) materialize a ~/.netrc from the token secret.
# --system so the rewrite is visible to every UID, incl. the runtime user.
RUN git config --system url."https://github.com/".insteadOf "git@github.com:"

# The runtime user needs a writable HOME: go build cache, module cache and
# the materialized ~/.netrc all live under it. The base image's HOME is not
# writable by our UID.
RUN mkdir -p /home/renovate/.cache/go-build /home/renovate/go \
 && chown -R 12021:12021 /home/renovate

USER 12021

ENV PATH="/usr/local/go/bin:${PATH}"
ENV HOME=/home/renovate
