#!/usr/bin/env bash

export LANG=C
set -ue

PARAM="${1:-}"

SCRIPT_DIR=$(cd -P $(dirname "$0"); pwd -P)
WORK_DIR=$(mktemp -d)

JOBS=$(nproc)
MP_MAKE="make -j$JOBS"

REDIRECT="2>&1"
LOGFILE=">$SCRIPT_DIR/log.txt"
if [ "$PARAM" = "on_docker" ]; then
    REDIRECT=""
    LOGFILE=""
fi

ZLIB_TARBALL_URL="http://zlib.net/zlib-1.2.8.tar.gz"
ZLIB_NAME=$(basename "$ZLIB_TARBALL_URL" .tar.gz)

LIBIDN_TARBALL_URL="http://ftp.gnu.org/gnu/libidn/libidn-1.30.tar.gz"
LIBIDN_NAME=$(basename "$LIBIDN_TARBALL_URL" .tar.gz)

LIBRESSL_TARBALL_URL="http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.3.1.tar.gz"
LIBRESSL_NAME=$(basename "$LIBRESSL_TARBALL_URL" .tar.gz)

LIBSSH2_TARBALL_URL="http://www.libssh2.org/download/libssh2-1.6.0.tar.gz"
LIBSSH2_NAME=$(basename "$LIBSSH2_TARBALL_URL" .tar.gz)

CURL_TARBALL_URL="http://curl.haxx.se/download/curl-7.45.0.tar.gz"
CURL_NAME=$(basename "$CURL_TARBALL_URL" .tar.gz)

notice() { echo "$@" >&2; }

download() {
    local TARBALL=$(basename "$1")
    if [ ! -f "$TARBALL" ]; then
        notice "  Downloading $TARBALL"
        wget -q -O "$TARBALL" "$1"
    fi
}

extract() {
    local ARCHIVE=$(basename "$1")
    notice "  Extracting $ARCHIVE"
    tar xf "$ARCHIVE"
}

dlext() {
    download "$1"
    extract "$1"
}

_build_zlib() {
(
    cd "$WORK_DIR/$ZLIB_NAME"

    CFLAGS="-I$WORK_DIR/include" \
    LDFLAGS="-L$WORK_DIR/lib" \
    ./configure --prefix="$WORK_DIR" \
                --static

    make clean
    $MP_MAKE
    make install
)
}

_build_libidn() {
(
    cd "$WORK_DIR/$LIBIDN_NAME"

    CFLAGS="-I$WORK_DIR/include" \
    LDFLAGS="-L$WORK_DIR/lib" \
    ./configure --prefix="$WORK_DIR" \
                --disable-shared \
                --disable-csharp \
                --disable-java

    make clean
    $MP_MAKE
    make install
)
}

_build_libressl() {
(
    cd "$WORK_DIR/$LIBRESSL_NAME"

    CFLAGS="-I$WORK_DIR/include" \
    LDFLAGS="-L$WORK_DIR/lib" \
    ./configure --prefix="$WORK_DIR" \
                --disable-shared \
                --enable-static

    make clean
    $MP_MAKE
    make install
)
}

_build_libssh2() {
(
    cd "$WORK_DIR/$LIBSSH2_NAME"

    CFLAGS="-I$WORK_DIR/include" \
    LDFLAGS="-L$WORK_DIR/lib" \
    ./configure --prefix="$WORK_DIR" \
                --with-libz-prefix="$WORK_DIR" \
                --with-libssl-prefix="$WORK_DIR" \
                --disable-shared \
                --enable-static

    make clean
    $MP_MAKE
    make install
)
}

_build_curl() {
(
    cd "$WORK_DIR/$CURL_NAME"

    CFLAGS="-I$WORK_DIR/include" \
    LDFLAGS="-L$WORK_DIR/lib" \
    ./configure --prefix="$WORK_DIR" \
                --with-zlib="$WORK_DIR" \
                --with-ssl="$WORK_DIR" \
                --with-libssh2="$WORK_DIR" \
                --without-ca-path \
                --without-ca-bundle \
                --disable-shared \
                --enable-static \
                --disable-imap \
                --disable-ldap \
                --disable-ldaps \
                --disable-rtsp \
                --disable-gopher \
                --without-librtmp \
                --without-nghttp2

    make clean
    $MP_MAKE
    make install
)
}

build_all() {
    notice "Create work directory"
    mkdir -p "$WORK_DIR" >/dev/null 2>&1

    notice "Downloading and extracting dependency libraries."
    (
        cd "$WORK_DIR"
        dlext "$ZLIB_TARBALL_URL"
        dlext "$LIBIDN_TARBALL_URL"
        dlext "$LIBRESSL_TARBALL_URL"
        dlext "$LIBSSH2_TARBALL_URL"
        dlext "$CURL_TARBALL_URL"
    )

    notice "Building and installing ZLib."
    eval "_build_zlib $REDIRECT"

    notice "Building and installing libidn."
    eval "_build_libidn $REDIRECT"

    notice "Building and installing libressl."
    eval "_build_libressl $REDIRECT"

    notice "Building and installing libssh2."
    eval "_build_libssh2 $REDIRECT"

    notice "Building and installing curl."
    eval "_build_curl $REDIRECT"

    notice "Copy built curl to current directory."
    cp "$WORK_DIR/bin/curl" "$SCRIPT_DIR"

    notice "Done."
}

eval "build_all $LOGFILE"
