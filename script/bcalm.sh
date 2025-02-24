#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

cmake -LH .

# Configure CMake with Zig compiler
cmake \
    -DKSIZE_LIST="32 64 96 128" \
    -DCMAKE_BUILD_TYPE=Release \
    -Wno-dev -DBUILD_TESTING=OFF \
    -S . -B build
#     # -DBUILD_STATIC_EXECS=ON \

# Build the project
cmake --build build -- -j 8 || exit 1

# Collect binaries
collect_bins "build/bcalm"

# Use build_tar function from common.sh
build_tar
