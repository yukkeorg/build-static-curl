FROM debian

RUN apt-get update && \
    apt-get install -y wget file tar make gcc cpp pkg-config automake autoconf build-essential mingw-w64

WORKDIR /build

VOLUME ["/build"]
CMD ["/bin/bash", "build_static_curl.bash"]
