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
    make host               # out/yarr

    # cross-compile Linux service binaries
    make linux_amd64
    make linux_arm64

    # ... or build a docker image
    docker build -t yarr

Run locally:

    ./out/yarr -addr 127.0.0.1:7070 -db local.db

Build a multi-arch image:

    docker buildx build \
      --platform linux/amd64,linux/arm64 \
      -t yarr:latest

Run the image:

    docker run -it --rm \
      -p 7070:7070 \
      -v yarr_data:/data \
      yarr:latest -addr 0.0.0.0:7070 -db /data/yarr.db
