#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ./configure --help

# TODO
# checking for /home/wangq/binzlibVersion in -lz... no
# configure: error: zlib not installed

# Build with the specified target architecture
CC="zig cc -target ${TARGET_ARCH}" \
CXX="zig c++ -target ${TARGET_ARCH}" \
    ./configure \
    --prefix="${TEMP_DIR}/collect" \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --with-zlib-prefix="${HOME}/bin" \
    || exit 1
make -j 8 || exit 1
make install || exit 1
# CFLAGS="-I$HOME/bin/include" \
# LDFLAGS="-L$HOME/bin/lib" \

tree "${TEMP_DIR}/collect"

# # Use build_tar function from common.sh
# build_tar
