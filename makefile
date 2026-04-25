VERSION := $(shell git describe --tags --always --dirty 2>/dev/null | sed 's/^v//')
GITHASH := $(shell git rev-parse --short=8 HEAD 2>/dev/null || echo unknown)

GO_TAGS    = sqlite_foreign_keys sqlite_json
GO_LDFLAGS = -s -w -X 'main.Version=$(VERSION)' -X 'main.GitHash=$(GITHASH)'

GO_FLAGS       = -tags "$(GO_TAGS)" -ldflags="$(GO_LDFLAGS)"
GO_FLAGS_DEBUG = -tags "$(GO_TAGS) debug"

export CGO_ENABLED=1

default: test

docker:
	docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg GITHASH=$(GITHASH) \
		-t yarr:$(VERSION) .

docker-multiarch:
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg VERSION=$(VERSION) \
		--build-arg GITHASH=$(GITHASH) \
		-t yarr:$(VERSION) .

serve:
	go run $(GO_FLAGS_DEBUG) ./cmd/yarr -db local.db

test:
	go test $(GO_FLAGS) ./...

.PHONY: \
	docker docker-multiarch \
	serve test
