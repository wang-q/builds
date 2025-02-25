#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# cmake -LH .

# Configure CMake with Zig compiler
# ASM="zig cc" \
# CC="zig cc" \
# CXX="zig c++" \
cmake \
    -DCMAKE_ASM_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_C_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_CXX_COMPILER_TARGET="${TARGET_ARCH}" \
    -DBOOST_ROOT="${PWD}" \
    -DCMAKE_INSTALL_PREFIX="${TEMP_DIR}/collect" \
    -DBOOST_ENABLE_PYTHON=OFF \
    -DBOOST_ENABLE_MPI=OFF \
    -DBOOST_IOSTREAMS_ENABLE_BZIP2=OFF \
    -DBOOST_IOSTREAMS_ENABLE_LZMA=OFF \
    -DBOOST_IOSTREAMS_ENABLE_ZSTD=OFF \
    -DBOOST_LOCALE_ENABLE_ICU=OFF \
    -S . -B build

# # Build the project
# cmake --build build -- -j 8 || exit 1

# # Collect binaries
# collect_bins "build/bin/spoa"

# # Use build_tar function from common.sh
# build_tar
