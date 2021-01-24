# Copyright Anant Haral
# SPDX-License-Identifier: MIT

BUILD_TIME=$(shell sh -c 'date +%FT%T%z')
VERSION := $(shell sh -c 'git describe --always --tags')
BRANCH := $(shell sh -c 'git rev-parse --abbrev-ref HEAD')
COMMIT := $(shell sh -c 'git rev-parse --short HEAD')
GIT_SHORT_HASH := $(shell sh -c 'git rev-parse --short HEAD')
LDFLAGS=-ldflags "-s -w -X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.branch=$(BRANCH) -X main.buildDate=$(BUILD_TIME)"
TIMESTAMP := $(shell date +'%s')

# Go Formatting
fmt:
	@gofmt -w -l -s $(GO_FILES)
	@goimports -w -l $(GO_FILES)

.PHONY: dependencies deps
dependencies: deps

deps:
	go env -w GOPRIVATE=github.com/anantxx/CaseStudy-User/*
	go mod download

.PHONY: build
build: deps
	@echo "Building Linux on amd64..."
	env GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o backend main.go

.PHONY: build-mac
build-mac: deps
	@echo "Building darwin on amd64..."
	env GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o backend main.go

.PHONY: build-linux
build-linux: deps
	@echo "Building linux on amd64..."
	env GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o backend main.go


.PHONY: clean
clean:
	rm -f ./backend

.PHONY: build-docker-image
build-docker-images: build_docker_image

.PHONY: build_docker_image
build_docker_image:
	@echo "Build Commit  : $(COMMIT)"
	@echo "Build Branch  : $(BRANCH)"
	@echo "Build Time    : $(BUILD_TIME)"
	docker build \
		--build-arg BUILD_VERSION=$(VERSION) \
		--build-arg BUILD_COMMIT=$(COMMIT) \
		--build-arg BUILD_BRANCH=$(BRANCH) \
		--build-arg BUILD_TIME=$(BUILD_TIME) \
		-t user ./

.PHONY: start
start: build
	./backend server

