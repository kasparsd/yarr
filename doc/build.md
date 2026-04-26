# Build

This project is released as a container image. The local workflow is either:

* run the app directly with Go during development
* build and run the Docker image

## Prerequisites

* Go >= 1.23 for `make serve` and `make test`
* A C compiler for CGO-backed SQLite builds
* Docker for local image builds
* Docker Buildx for multi-arch image builds

## Local development

Run the app directly:

```sh
make serve
```

Run the app in the development container:

```sh
make docker-dev
```

Open a shell in the development container and run build or test commands there:

```sh
make docker-dev-shell
docker compose run --rm yarr-dev make build
docker compose run --rm yarr-dev make test
```

Run the test suite:

```sh
make test
```

## Local image build

Build the local image:

```sh
make docker
```

The production image stays minimal and does not include the build toolchain. The development container uses the Dockerfile `dev` stage and mounts the source tree plus Go build caches.

Run the image:

```sh
docker run -it --rm \
    -p 7070:7070 \
    -v yarr_data:/data \
    yarr:$(git describe --tags --always --dirty | sed 's/^v//') \
    -addr 0.0.0.0:7070 \
    -db /data/yarr.db
```

Build the multi-arch image locally:

```sh
make docker-multiarch
```

## Versioning

Image build metadata is derived from Git:

* release tags such as `v2.6` become embedded version `2.6`
* untagged builds use `git describe --tags --always --dirty`
* the short Git hash is injected separately and shown by `yarr -version`

You can verify the version in a built image with:

```sh
docker run --rm yarr:$(git describe --tags --always --dirty | sed 's/^v//') -version
```

## Release process

1. Create and push a version tag such as `v2.7`.
2. The build workflow validates the Docker image on pushes and pull requests.
3. The publish workflow builds and pushes the multi-arch image to the registry.
