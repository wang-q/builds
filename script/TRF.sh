#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Build with the specified target architecture
CC="zig cc -target ${TARGET_ARCH}" \
    ./configure \
    --prefix="${TEMP_DIR}/collect" \
    --bindir="${TEMP_DIR}/collect" \
    --disable-dependency-tracking \
    --disable-silent-rules \
    || exit 1
make || exit 1
make install || exit 1

rm ${TEMP_DIR}/collect/trf4.10.0-rc.2.linux64.exe

# Use build_tar function from common.sh
build_tar
