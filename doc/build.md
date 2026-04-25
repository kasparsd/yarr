# Build

## Compilation

Prerequisies:

* Go >= 1.23
* C Compiler (GCC / Clang / ...)
* Zig >= 0.14.0 (optional, for Linux cross-compilation)

Get the source code:

    git clone https://github.com/nkanaev/yarr.git

Compile:

    # build the service binary for the host OS/architecture
    make host               # dist/host/yarr

    # cross-compile Linux service binaries
    make linux_amd64
    make linux_arm64

    # create release archives and checksums under dist/
    make release

    # ... or build a docker image
    docker build -t yarr .

Run locally:

    ./dist/host/yarr -addr 127.0.0.1:7070 -db local.db

Build a multi-arch image:

    docker buildx build \
      --platform linux/amd64,linux/arm64 \
      -t yarr:latest \
      -f Dockerfile \
      .

Run the image:

    docker run -it --rm \
      -p 7070:7070 \
      -v yarr_data:/data \
      yarr:latest -addr 0.0.0.0:7070 -db /data/yarr.db

## Versioning

Build metadata is derived from Git:

* release tags such as `v2.6` become binary version `2.6`
* untagged builds use `git describe --tags --always --dirty`
* the short Git hash is injected separately and shown by `yarr -version`

## Release process

1. Create and push a version tag such as `v2.7`.
2. The GitHub release workflow builds Linux `amd64` and `arm64` archives plus a SHA256 checksum file.
    Artifact names follow the dashed form `yarr-<version>-linux-amd64.tar.gz`, `yarr-<version>-linux-arm64.tar.gz`, and `yarr-<version>-checksums.txt`.
3. The Docker publish workflow builds and pushes the multi-arch image.
4. Verify the resulting binary reports the expected version with `./dist/host/yarr -version` or by running a release artifact.
