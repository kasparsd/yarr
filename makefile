RAW_VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
VERSION := $(patsubst v%,%,$(RAW_VERSION))
GITHASH ?= $(shell git rev-parse --short=8 HEAD 2>/dev/null || echo unknown)

GO_TAGS = sqlite_foreign_keys sqlite_json
GO_LDFLAGS = -s -w -X 'main.Version=$(VERSION)' -X 'main.GitHash=$(GITHASH)'

GO_FLAGS = -tags "$(GO_TAGS)" -ldflags="$(GO_LDFLAGS)"
GO_FLAGS_DEBUG = -tags "$(GO_TAGS) debug"

TARGETOS ?= $(shell go env GOOS)
TARGETARCH ?= $(shell go env GOARCH)

OUT ?= ./out/yarr
CMD ?= sh

export CGO_ENABLED=1

default: test

build:
	mkdir -p $(dir $(OUT))
	go build $(GO_FLAGS) -o $(OUT) ./cmd/yarr

release: OUT = ./out/yarr-$(TARGETOS)-$(TARGETARCH)
release: build

build-docker:
	docker build \
		-t yarr:$(VERSION) .

build-docker-multiarch:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		-t yarr:$(VERSION) .

dev-docker:
	docker compose run --rm --service-ports yarr-dev $(CMD)

serve:
	go run $(GO_FLAGS_DEBUG) ./cmd/yarr -db local.db

test:
	go test $(GO_FLAGS) ./...

.PHONY: \
	build release \
	build-docker build-docker-multiarch dev-docker \
	serve test
