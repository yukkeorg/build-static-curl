FROM debian:9

RUN apt-get update && \
    apt-get install -y wget file tar make gcc cpp pkg-config automake autoconf

WORKDIR /build
COPY build_static_curl.bash /build

ENTRYPOINT ["/bin/bash", "build_static_curl.bash"]
VOLUME ["/build/out"]
