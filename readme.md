# yarr

**yarr** (yet another rss reader) is a self-hosted feed reader service with an embedded web frontend and REST API.

The app is a single binary with an embedded database (SQLite).

![screenshot](etc/promo.png)

## quick start

Run the published container image or build one locally. The supported deployment targets are Linux containers for `amd64` and `arm64`.

```sh
docker run -d \
  --name yarr \
  -p 7070:7070 \
  -v yarr_data:/data \
  -e YARR_ADDR=0.0.0.0:7070 \
  ghcr.io/kasparsd/yarr:latest
```

Open `http://localhost:7070` in a browser.

To enable HTTP basic auth:

```sh
docker run -d \
  --name yarr \
  -p 7070:7070 \
  -v yarr_data:/data \
  -e YARR_ADDR=0.0.0.0:7070 \
  -e YARR_AUTH=admin:change-me \
  ghcr.io/kasparsd/yarr:latest
```

The service stores its SQLite database at `/data/yarr.db` by default in the container.

## configuration

Configuration is available via flags or environment variables:

* `-addr` / `YARR_ADDR`: bind address, for example `0.0.0.0:7070`
* `-db` / `YARR_DB`: database path
* `-auth` / `YARR_AUTH`: HTTP basic auth as `username:password`
* `-auth-file` / `YARR_AUTHFILE`: path to a file containing `username:password`
* `-base` / `YARR_BASE`: optional base path prefix
* `-cert-file` / `YARR_CERTFILE`: TLS certificate path
* `-key-file` / `YARR_KEYFILE`: TLS private key path
* `-log-file` / `YARR_LOGFILE`: optional log file path

See `yarr -h` for the full runtime help text.

## development

Prerequisites:

* Go >= 1.23 for `make serve` and `make test`
* A C compiler for CGO-backed SQLite builds
* Docker for local image builds
* Docker Buildx for multi-arch image builds

Local development run:

```sh
make serve
```

Development container shell:

```sh
make dev-docker
```

Development container server:

```sh
make dev-docker CMD='make serve'
```

Run build or test commands in the development container:

```sh
make dev-docker CMD='make build'
make dev-docker CMD='make test'
docker compose run --rm yarr-dev make test
```

Run the test suite:

```sh
make test
```

Local image build:

```sh
make build-docker
```

The production image stays minimal and does not include the build toolchain. The development container uses the Dockerfile `dev` stage and mounts the source tree into `/src`.

Run the image:

```sh
docker run -it --rm \
  -p 7070:7070 \
  -v yarr_data:/data \
  yarr:$(git describe --tags --always --dirty | sed 's/^v//') \
  -addr 0.0.0.0:7070 \
  -db /data/yarr.db
```

Tagged releases derive the embedded version from Git tags. Untagged builds fall back to the nearest Git description plus the short commit hash.

Multi-arch image build:

```sh
make build-docker-multiarch
```

Versioning:

* release tags such as `v2.6` become embedded version `2.6`
* untagged builds use `git describe --tags --always --dirty`
* the short Git hash is injected separately and shown by `yarr -version`

You can verify the version in a built image with:

```sh
docker run --rm yarr:$(git describe --tags --always --dirty | sed 's/^v//') -version
```

## releases

Pushing a `v*` Git tag publishes:

* Multi-arch container images to `ghcr.io/kasparsd/yarr`

Release process:

1. Create and push a version tag such as `v2.7`.
2. The test workflow validates the containerized build and test steps on pushes and pull requests.
3. The publish workflow builds and pushes the multi-arch image to the registry.

See more:

* [Fever API support](doc/fever.md)

## credits

[Feather](http://feathericons.com/) for icons.
