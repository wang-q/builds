#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# cmake -LAH .
# cmake -LH .

# Configure CMake with Zig compiler
ASM="zig cc" \
CC="zig cc" \
CXX="zig c++" \
CFLAGS="-I$HOME/bin/include" \
LDFLAGS="-L$HOME/bin/lib" \
cmake \
    -DCMAKE_ASM_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_C_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_CXX_COMPILER_TARGET="${TARGET_ARCH}" \
    -DZLIB_INCLUDE_DIR="$HOME/bin/include" \
    -DZLIB_LIBRARY="$HOME/bin/lib/libz.a" \
    -DCMAKE_CXX_FLAGS="-Wno-unqualified-std-cast-call" \
    -DMAX_KMER_SIZE=128 \
    -S . -B build

# Build the project
cmake --build build -- -j 8 || exit 1

# Collect binaries based on OS type
if [[ "${OS_TYPE}" == "linux" ]]; then
    collect_bins build/src/Bifrost build/src/libbifrost.so
else
    collect_bins build/src/Bifrost build/src/libbifrost.dylib
fi

# Use build_tar function from common.sh
build_tar
