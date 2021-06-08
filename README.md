## static-curl-build-script

static cURL program (with zlib, libidn, libressl and libssh2) build script

### Standalone

``` sh
  $ git pull https://github.com/yukkeorg/static-curl-build-script.git
  $ cd static-curl-build-script
  $ ./build_static_curl.bash
```

### With docker

``` sh
  $ git pull https://github.com/yukkeorg/static-curl-build-script.git
  $ cd static-curl-build-script
  $ docker build -f Dockerfile.debian8 .
```

Copy the buiut curl from docker image.

``` sh
  $ docker cp <latest image id>:/home/build/curl .
```

### LICENSE

Public domain
