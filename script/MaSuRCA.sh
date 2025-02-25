#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# Set configure options based on OS type
export CC="zig cc -target ${TARGET_ARCH}"
export CXX="zig c++ -target ${TARGET_ARCH}"
export DEST="${TEMP_DIR}/collect"

bash install.sh

# ./configure \
#     --prefix="${TEMP_DIR}/collect" \
#     --bindir="${TEMP_DIR}/collect" \
#     ${SIMD_OPT} \
#     --enable-threads \
#     || exit 1
# make -j 8 || exit 1
# make install || exit 1

tree collect

# # Use build_tar function from common.sh
# build_tar
