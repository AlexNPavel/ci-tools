SHELL=/usr/bin/env bash -o pipefail

export GOPROXY=https://proxy.golang.org,direct

all: lint test build
.PHONY: all

build:
	go build ./cmd/...
.PHONY: build

install:
	go install ./cmd/...
.PHONY: install

test:
	go test -race ./...
.PHONY: test

validate-vendor:
	go version
	go mod tidy
	git status -s go.mod go.sum
	test -z "$$(git status -s go.mod go.sum)"
.PHONY: validate-vendor

lint:
	gofmt -s -l $(shell go list -f '{{ .Dir }}' ./... ) | grep ".*\.go"; if [ "$$?" = "0" ]; then gofmt -s -d $(shell go list -f '{{ .Dir }}' ./... ); exit 1; fi
	go vet ./...
.PHONY: lint

format:
	gofmt -s -w $(shell go list -f '{{ .Dir }}' ./... )
.PHONY: format

integration: integration-prowgen integration-pj-rehearse integration-ci-operator integration-ci-operator-configresolver integration-secret-wrapper integration-testgrid-generator integration-repo-init integration-group-auto-updater integration-ci-op-configs-mirror
.PHONY: integration

integration-prowgen:
	test/prowgen-integration/run.sh
	test/prowgen-integration/run.sh subdir
.PHONY: integration-prowgen

integration-pj-rehearse:
	test/pj-rehearse-integration/run.sh
.PHONY: integration-pj-rehearse

integration-ci-operator:
	test/ci-operator-integration/base/run.sh
	test/ci-operator-integration/multi-stage/run.sh
.PHONY: integration-ci-operator

integration-ci-operator-configresolver:
	test/ci-operator-configresolver-integration/run.sh
.PHONY: integration-ci-operator-configresolver

integration-secret-wrapper:
	test/secret-wrapper-integration.sh
.PHONY: integration-secret-wrapper

integration-testgrid-generator:
	test/testgrid-config-generator/run.sh
.PHONY: integration-testgrid-generator

integration-repo-init:
	test/repo-init-integration/run.sh
.PHONY: integration-repo-init

check-breaking-changes:
	test/validate-prowgen-breaking-changes.sh
.PHONY: check-breaking-changes

integration-group-auto-updater:
	test/group-auto-updater-integration/run.sh
.PHONY: integration-group-auto-updater

integration-ci-op-configs-mirror:
	test/ci-op-configs-mirror-integration/run.sh
.PHONY: integration-ci-op-configs-mirror
