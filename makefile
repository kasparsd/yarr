VERSION := $(shell git describe --tags --always --dirty 2>/dev/null | sed 's/^v//')
GITHASH := $(shell git rev-parse --short=8 HEAD 2>/dev/null || echo unknown)

DIST_DIR            := dist
HOST_BIN            := $(DIST_DIR)/host/yarr
RELEASE_DIR         := $(DIST_DIR)/release/$(VERSION)
LINUX_AMD64_BIN     := $(RELEASE_DIR)/linux_amd64/yarr
LINUX_ARM64_BIN     := $(RELEASE_DIR)/linux_arm64/yarr
LINUX_AMD64_ARCHIVE := $(DIST_DIR)/yarr_$(VERSION)_linux_amd64.tar.gz
LINUX_ARM64_ARCHIVE := $(DIST_DIR)/yarr_$(VERSION)_linux_arm64.tar.gz
CHECKSUM_FILE       := $(DIST_DIR)/yarr_$(VERSION)_checksums.txt

GO_TAGS    = sqlite_foreign_keys sqlite_json
GO_LDFLAGS = -s -w -X 'main.Version=$(VERSION)' -X 'main.GitHash=$(GITHASH)'

GO_FLAGS       = -tags "$(GO_TAGS)" -ldflags="$(GO_LDFLAGS)"
GO_FLAGS_DEBUG = -tags "$(GO_TAGS) debug"

export CGO_ENABLED=1

default: test host

# build targets

host:
	mkdir -p $(dir $(HOST_BIN))
	go build $(GO_FLAGS) -o $(HOST_BIN) ./cmd/yarr

check_zig:
	@command -v zig >/dev/null 2>&1 || { echo "zig >= 0.14.0 is required for Linux cross-compilation"; exit 1; }

linux_amd64: check_zig
	mkdir -p $(dir $(LINUX_AMD64_BIN))
	CC="zig cc -target x86_64-linux-musl -O2 -g0" CGO_CFLAGS="-D_LARGEFILE64_SOURCE" GOOS=linux GOARCH=amd64 \
	go build $(GO_FLAGS) -o $(LINUX_AMD64_BIN) ./cmd/yarr

linux_arm64: check_zig
	mkdir -p $(dir $(LINUX_ARM64_BIN))
	CC="zig cc -target aarch64-linux-musl -O2 -g0" CGO_CFLAGS="-D_LARGEFILE64_SOURCE" GOOS=linux GOARCH=arm64 \
	go build $(GO_FLAGS) -o $(LINUX_ARM64_BIN) ./cmd/yarr

release: $(LINUX_AMD64_ARCHIVE) $(LINUX_ARM64_ARCHIVE) $(CHECKSUM_FILE)

$(LINUX_AMD64_ARCHIVE): linux_amd64
	tar -C $(dir $(LINUX_AMD64_BIN)) -czf $@ yarr

$(LINUX_ARM64_ARCHIVE): linux_arm64
	tar -C $(dir $(LINUX_ARM64_BIN)) -czf $@ yarr

$(CHECKSUM_FILE): $(LINUX_AMD64_ARCHIVE) $(LINUX_ARM64_ARCHIVE)
	cd $(DIST_DIR) && shasum -a 256 $(notdir $(LINUX_AMD64_ARCHIVE)) $(notdir $(LINUX_ARM64_ARCHIVE)) > $(notdir $@)

docker:
	docker build -t yarr:$(VERSION) .

docker-multiarch:
	docker buildx build --platform linux/amd64,linux/arm64 -t yarr:$(VERSION) .

serve:
	go run $(GO_FLAGS_DEBUG) ./cmd/yarr -db local.db

test:
	go test $(GO_FLAGS) ./...

clean:
	rm -rf $(DIST_DIR)

.PHONY: \
	check_zig \
	host \
	linux_amd64 linux_arm64 \
	release \
	docker docker-multiarch \
	serve test clean
