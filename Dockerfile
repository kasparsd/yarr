ARG GO_VERSION=1.23
ARG ALPINE_VERSION=3.21
ARG VERSION=dev
ARG GITHASH=unknown

FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS build
ARG VERSION=dev
ARG GITHASH=unknown
RUN apk add build-base git
WORKDIR /src
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/root/go/pkg \
  go build -tags "sqlite_foreign_keys sqlite_json" -ldflags="-s -w -X main.Version=${VERSION#v} -X main.GitHash=${GITHASH}" -o /out/yarr ./cmd/yarr

FROM alpine:${ALPINE_VERSION}
RUN apk add --no-cache ca-certificates && update-ca-certificates
COPY --from=build /out/yarr /usr/local/bin/yarr
EXPOSE 7070
ENTRYPOINT ["/usr/local/bin/yarr"]
CMD ["-addr", "0.0.0.0:7070", "-db", "/data/yarr.db"]