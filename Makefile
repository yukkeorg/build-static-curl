.PHONY: native win32 docker

native:
	bash ./build_static_curl.bash

win32:
	VERBOSE=1 CROSS_HOST=i686_w64_mingw32 bash ./build_static_curl.bash

docker-build:
	docker build --tag "curl-static-build" .

docker: docker-build
	docker run --rm -v "${CURDIR}:/build" curl-static-build

docker-w32: docker-build
	docker run --rm -v "${CURDIR}:/build" -e CROSS_HOST=i686-w64-mingw32 curl-static-build
