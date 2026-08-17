# renovate: pin Renovate base image
ARG RENOVATE_BASE=ghcr.io/renovatebot/renovate:44.32.2
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
RUN git config --global url."https://github.com/".insteadOf "git@github.com:"

USER 12021

ENV PATH="/usr/local/go/bin:${PATH}"
