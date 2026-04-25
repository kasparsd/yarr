VERSION=2.6
GITHASH=$(shell git rev-parse --short=8 HEAD)

GO_TAGS    = sqlite_foreign_keys sqlite_json
GO_LDFLAGS = -s -w -X 'main.Version=$(VERSION)' -X 'main.GitHash=$(GITHASH)'

GO_FLAGS       = -tags "$(GO_TAGS)" -ldflags="$(GO_LDFLAGS)"
GO_FLAGS_DEBUG = -tags "$(GO_TAGS) debug"

export CGO_ENABLED=1

default: test host

# build targets

host:
	go build $(GO_FLAGS) -o out/yarr ./cmd/yarr

linux_amd64:
	CC="zig cc -target x86_64-linux-musl -O2 -g0" CGO_CFLAGS="-D_LARGEFILE64_SOURCE" GOOS=linux GOARCH=amd64 \
	go build $(GO_FLAGS) -o out/$@/yarr ./cmd/yarr

linux_arm64:
	CC="zig cc -target aarch64-linux-musl -O2 -g0" CGO_CFLAGS="-D_LARGEFILE64_SOURCE" GOOS=linux GOARCH=arm64 \
	go build $(GO_FLAGS) -o out/$@/yarr ./cmd/yarr

serve:
	go run $(GO_FLAGS_DEBUG) ./cmd/yarr -db local.db

test:
	go test $(GO_FLAGS) ./...

.PHONY: \
	host \
	linux_amd64 linux_arm64 \
	serve test
