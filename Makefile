.PHONY: all
all: lint test

.PHONY: test
test: go-test

.PHONY: lint
lint: go-mod go-vet go-fmt go-imports

.PHONY: go-mod
go-mod:
	go mod tidy

.PHONY: go-vet
go-vet:
	go vet ./...

.PHONY: go-fmt
go-fmt:
	gofmt -w .

.PHONY: go-imports
go-imports:
	go install golang.org/x/tools/cmd/goimports@latest
	goimports -w .

.PHONY: go-test
go-test:
	go test ./...

CONTAINER_TOOL ?= docker
IMG ?= ict-harbor-pro-registry-huabei2.crs.ctyun.cn/ict/node-agent:v1.0.0
PLATFORMS ?= linux/arm64,linux/amd64
VERSION ?=v1.0.0
.PHONY: docker-buildx
docker-buildx: ## Build and push docker image for the manager for cross-platform support
	# copy existing Dockerfile and insert --platform=${BUILDPLATFORM} into Dockerfile.cross, and preserve the original Dockerfile
	sed -e '1 s/\(^FROM\)/FROM --platform=\$$\{BUILDPLATFORM\}/; t' -e ' 1,// s//FROM --platform=\$$\{BUILDPLATFORM\}/' Dockerfile > Dockerfile.cross
	- $(CONTAINER_TOOL) buildx create --name kube-builder --config buildkitd.toml
	$(CONTAINER_TOOL) buildx use kube-builder
	- $(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) --tag ${IMG} --build-arg VERSION=$(VERSION) -f Dockerfile.cross  .
	- $(CONTAINER_TOOL) buildx rm kube-builder
	rm Dockerfile.cross
