ARG ALPINE_VERSION=3.18
FROM golang:1.21-alpine${ALPINE_VERSION} AS builder

RUN apk add --no-cache git wget tar

WORKDIR /cerbos

COPY gateway ./gateway
COPY go.mod go.sum main.go ./

RUN go get -d -v ./...
RUN CGO_ENABLED=0 go build -ldflags '-s -w' -o /gw main.go
RUN chmod +x /gw

ARG CERBOS_RELEASE=0.45.0
ARG ARCH=x86_64
RUN mkdir -p /cerbos \
  && wget -qO- \
  "https://github.com/cerbos/cerbos/releases/download/v${CERBOS_RELEASE}/cerbos_${CERBOS_RELEASE}_linux_${ARCH}.tar.gz" \
  | tar xz --strip-components=1 -C /cerbos

FROM gcr.io/distroless/base
ARG ARCH=x86_64

COPY --from=builder /gw /gw
COPY --from=builder /cerbos/cerbos /cerbos
COPY conf.default.yml /conf.yml

ENTRYPOINT ["/gw"]
