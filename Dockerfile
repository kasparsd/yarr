ARG GO_VERSION=1.23
ARG ALPINE_VERSION=3.21

# Development tooling.
FROM golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS dev
RUN apk add --no-cache build-base git make
WORKDIR /src

# Builder.
FROM dev AS build
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/root/go/pkg \
  make build

# Final release.
FROM alpine:${ALPINE_VERSION}
RUN apk add --no-cache ca-certificates && update-ca-certificates
COPY --from=build /src/out/yarr /usr/local/bin/yarr
EXPOSE 7070
ENTRYPOINT ["/usr/local/bin/yarr"]
CMD ["-addr", "0.0.0.0:7070", "-db", "/data/yarr.db"]