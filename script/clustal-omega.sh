#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# ./configure --help

# Build mummer with the specified target architecture
CC="zig cc -target ${TARGET_ARCH}" \
CXX="zig c++ -target ${TARGET_ARCH}" \
AR="zig ar" \
CFLAGS="-I$HOME/bin/include" \
LDFLAGS="-L$HOME/bin/lib -static -largtable2" \
    ./configure \
    --prefix="${TEMP_DIR}/collect" \
    --bindir="${TEMP_DIR}/collect" \
    --disable-dependency-tracking \
    --disable-silent-rules \
    || exit 1
make || exit 1
make install || exit 1

# Use build_tar function from common.sh
build_tar
