.PHONY: all docker

all:

docker:
	docker build --tag "curl-static-build" .
	docker run --rm -v "${CURDIR}/:/build/out" curl-static-build
