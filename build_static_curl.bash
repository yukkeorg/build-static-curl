#!/usr/bin/env bash

export LANG=C
#set -eu

SCRIPT_DIR=$(cd -P $(dirname "$0"); pwd -P)
#WORK_DIR=$(mktemp -d)
WORK_DIR="$HOME/.build_static_curl"
JOBS=4


ZLIB_TARBALL_URL="http://zlib.net/zlib-1.2.8.tar.gz"
ZLIB_NAME=$(basename "$ZLIB_TARBALL_URL" .tar.gz)

LIBIDN_TARBALL_URL="http://ftp.gnu.org/gnu/libidn/libidn-1.30.tar.gz"
LIBIDN_NAME=$(basename "$LIBIDN_TARBALL_URL" .tar.gz)

OPENSSL_TARBALL_URL="https://www.openssl.org/source/openssl-1.0.2a.tar.gz"
OPENSSL_NAME=$(basename "$OPENSSL_TARBALL_URL" .tar.gz)

LIBSSH2_TARBALL_URL="http://www.libssh2.org/download/libssh2-1.5.0.tar.gz"
LIBSSH2_NAME=$(basename "$LIBSSH2_TARBALL_URL" .tar.gz)

CURL_TARBALL_URL="http://curl.haxx.se/download/curl-7.42.1.tar.gz"
CURL_NAME=$(basename "$CURL_TARBALL_URL" .tar.gz)


mkdir -p "$WORK_DIR" >/dev/null 2>&1
pushd "$WORK_DIR"

dlext() {
    local TARBALL=$(basename "$1")
    [ -f "$TARBALL" ] || wget -O "$TARBALL" "$1"
    tar xf "$TARBALL"
}

dlext "$ZLIB_TARBALL_URL"
dlext "$LIBIDN_TARBALL_URL"
dlext "$OPENSSL_TARBALL_URL"
dlext "$LIBSSH2_TARBALL_URL"
dlext "$CURL_TARBALL_URL"

pushd "$ZLIB_NAME"
./configure --prefix="$WORK_DIR" --static
make -j$JOBS
make install
popd

pushd "$LIBIDN_NAME"
./configure --prefix="$WORK_DIR" \
            --disable-shared \
            --disable-csharp \
            --disable-java
make -j$JOBS
make clean
make install
popd

pushd "$OPENSSL_NAME"
./config --prefix="$WORK_DIR" no-shared
make -j$JOBS
make clean
make install_sw
popd

pushd "$LIBSSH2_NAME"
LIBS="-ldl" \
./configure --prefix="$WORK_DIR" \
            --with-libz-prefix="$WORK_DIR" \
            --with-libssl-prefix="$WORK_DIR" \
            --disable-shared \
            --enable-static
make -j$JOBS
make clean
make install
popd

pushd "$CURL_NAME"
CPPFLAGS="-I$WORK_DIR/include" \
LDFLAGS="-L$WORK_DIR/lib" \
LIBS="-ldl" \
./configure --prefix="$WORK_DIR" \
            --with-zlib="$WORK_DIR" \
            --with-ssl="$WORK_DIR" \
            --with-libssh2="$WORK_DIR" \
            --disable-shared \
            --enable-static \
            --disable-imap \
            --disable-ldap \
            --disable-ldaps \
            --disable-rtsp \
            --disable-gopher \
            --without-librtmp \
            --without-nghttp2
make -j$JOBS
make clean
make install
popd

popd
