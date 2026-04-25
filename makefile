VERSION := $(shell git describe --tags --always --dirty 2>/dev/null | sed 's/^v//')
GITHASH := $(shell git rev-parse --short=8 HEAD 2>/dev/null || echo unknown)

DIST_DIR        := dist
HOST_BIN        := $(DIST_DIR)/host/yarr
RELEASE_DIR     := $(DIST_DIR)/release/$(VERSION)
RELEASE_PREFIX  := $(DIST_DIR)/yarr_$(VERSION)
CHECKSUM_FILE   := $(RELEASE_PREFIX)_checksums.txt

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

linux_amd64:
	mkdir -p $(RELEASE_DIR)/linux_amd64
	CC="zig cc -target x86_64-linux-musl -O2 -g0" CGO_CFLAGS="-D_LARGEFILE64_SOURCE" GOOS=linux GOARCH=amd64 \
	go build $(GO_FLAGS) -o $(RELEASE_DIR)/linux_amd64/yarr ./cmd/yarr

linux_arm64:
	mkdir -p $(RELEASE_DIR)/linux_arm64
	CC="zig cc -target aarch64-linux-musl -O2 -g0" CGO_CFLAGS="-D_LARGEFILE64_SOURCE" GOOS=linux GOARCH=arm64 \
	go build $(GO_FLAGS) -o $(RELEASE_DIR)/linux_arm64/yarr ./cmd/yarr

release: $(RELEASE_PREFIX)_linux_amd64.tar.gz $(RELEASE_PREFIX)_linux_arm64.tar.gz $(CHECKSUM_FILE)

$(RELEASE_PREFIX)_linux_amd64.tar.gz: linux_amd64
	tar -C $(RELEASE_DIR)/linux_amd64 -czf $@ yarr

$(RELEASE_PREFIX)_linux_arm64.tar.gz: linux_arm64
	tar -C $(RELEASE_DIR)/linux_arm64 -czf $@ yarr

$(CHECKSUM_FILE): $(RELEASE_PREFIX)_linux_amd64.tar.gz $(RELEASE_PREFIX)_linux_arm64.tar.gz
	cd $(DIST_DIR) && shasum -a 256 $(notdir $(RELEASE_PREFIX)_linux_amd64.tar.gz) $(notdir $(RELEASE_PREFIX)_linux_arm64.tar.gz) > $(notdir $@)

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
	host \
	linux_amd64 linux_arm64 \
	release \
	docker docker-multiarch \
	serve test clean
