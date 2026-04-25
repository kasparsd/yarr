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

Local development build:

```sh
make host
./dist/host/yarr -addr 127.0.0.1:7070 -db local.db
```

Tagged releases derive the embedded version from Git tags. Untagged builds fall back to the nearest Git description plus the short commit hash.

Binary release artifacts:

```sh
make release
ls dist/
```

This produces versioned Linux archives and a checksum file suitable for GitHub Releases.

Multi-arch image build:

```sh
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t yarr:latest \
  -f Dockerfile \
  .
```

## releases

Pushing a `v*` Git tag publishes:

* Linux release archives and SHA256 checksums to GitHub Releases
* Multi-arch container images to `ghcr.io/kasparsd/yarr`

See more:

* [Building from source code](doc/build.md)
* [Fever API support](doc/fever.md)

## credits

[Feather](http://feathericons.com/) for icons.
