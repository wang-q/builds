#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# Configure CMake with Zig compiler
./bootstrap.sh \
    --with-toolset=clang \
    --without-icu \
    --without-libraries=python,mpi,log

echo "using clang : zig : zig c++ ;" \
    > user-config.jam

./b2 headers

./b2 \
    --prefix="${TEMP_DIR}/collect" \
    -d2 \
    -j8 \
    --layout=system \
    --user-config=user-config.jam \
    threading=multi \
    link=shared,static \
    install

# # # Build the project
# # cmake --build build -- -j 8 || exit 1

# # # Collect binaries
# # collect_bins "build/bin/spoa"

# # # Use build_tar function from common.sh
# # build_tar
