PKG_LIST=$(shell go list ./... | grep -v /vendor/ |  grep -v /cmd)

all: build

test:
	@go test -race -short -v $(PKG_LIST)

clean:
	@go clean
	@rm -f bin/*

docker-build:
	@docker image build -f deploy/dockerfiles/uploader.Dockerfile -t mydds/uploader:latest .

docker-push:
	@docker image push ${REGISTRY}/${REPOSITORY}-uploader:${IMAGE_TAG}
