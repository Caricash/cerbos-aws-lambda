ARG ALPINE_VERSION=3.18
FROM golang:1.21-alpine${ALPINE_VERSION} AS builder

WORKDIR /cerbos

COPY gateway ./gateway
COPY go.mod go.sum main.go ./


RUN go get -d -v ./...
RUN CGO_ENABLED=0 go build -ldflags '-s -w' -o /gw main.go
RUN chmod +x /gw

FROM gcr.io/distroless/base
ARG ARCH=x86_64
COPY --from=builder /gw /
COPY .cerbos/Linux_${ARCH}/cerbos /
COPY conf.default.yml /conf.yml

ENTRYPOINT ["/gw"]
