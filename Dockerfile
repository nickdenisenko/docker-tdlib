FROM debian:bookworm AS builder

# https://github.com/tdlib/td/commit/0ece11a1ae5aa514a76a459f4904276494434bd2
ARG TD_COMMIT=0ece11a1ae5aa514a76a459f4904276494434bd2

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		git \
		make \
    ca-certificates \
    clang \
    cmake \
    gperf \
    libc++-dev \
    libc++abi-dev \
    libclang-rt-dev \
    libssl-dev \
    php-cli \
    zlib1g-dev \
	; \
	cd /tmp; \
  git clone --no-checkout --depth 1 https://github.com/tdlib/td.git; \
  cd td; \
  git fetch --depth 1 origin $TD_COMMIT; \
  git checkout $TD_COMMIT; \
  mkdir build; \
  cd build; \
  CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang CXX=/usr/bin/clang++ \
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ..; \
  cmake --build . --target install

FROM debian:bookworm

ARG TD_VERSION=1.8.51

COPY --from=builder /usr/local/lib/libtdjson.so.${TD_VERSION} /usr/local/lib/libtdjson.so.${TD_VERSION}
COPY --from=builder /usr/local/lib/libtdjson.so /usr/local/lib/libtdjson.so

RUN ldconfig