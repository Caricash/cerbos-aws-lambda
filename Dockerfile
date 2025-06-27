###############################################################################
# 1) Builder stage: compile gateway & fetch Cerbos server
###############################################################################
ARG ALPINE_VERSION=3.18
FROM golang:1.21-alpine${ALPINE_VERSION} AS builder

RUN apk add --no-cache git wget tar

WORKDIR /cerbos

# Build the Go gateway
COPY gateway ./gateway
COPY go.mod go.sum main.go ./
RUN go mod download \
  && CGO_ENABLED=0 go build -ldflags='-s -w' -o /gw main.go \
  && chmod +x /gw

# Download & unpack the Cerbos server binary
ARG CERBOS_RELEASE=0.45.0
ARG ARCH=x86_64
RUN mkdir -p /tmp/cerbos \
  && wget -qO- \
  "https://github.com/cerbos/cerbos/releases/download/v${CERBOS_RELEASE}/cerbos_${CERBOS_RELEASE}_Linux_${ARCH}.tar.gz" \
  | tar xz -C /tmp/cerbos \
  && chmod +x /tmp/cerbos/cerbos

###############################################################################
# 2) Runtime stage: Alpine with envsubst + your entrypoint
###############################################################################
FROM alpine:3.18 AS runtime

RUN apk add --no-cache gettext

# Gateway binary
COPY --from=builder /gw /gw

# Cerbos server binary
COPY --from=builder /tmp/cerbos/cerbos /cerbos

# Your Cerbos config template
COPY conf.default.yml /conf.yml

# The interpolation+launch script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
