#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# cmake -LH .

# Configure CMake with Zig compiler
ASM="zig cc" \
CC="zig cc" \
CXX="zig c++" \
cmake \
    -DCMAKE_ASM_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_C_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_CXX_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_SYSTEM_NAME="Linux" \
    -DCMAKE_SYSTEM_PROCESSOR="x86_64" \
    -DLIBOMP_INSTALL_ALIASES=OFF \
    -DLIBOMP_ENABLE_SHARED=OFF \
    -S . -B build

# # Build the project
cmake --build build -- -j 8 || exit 1

tree build

# # Collect binaries
# collect_bins "build/bin/spoa"

# # Use build_tar function from common.sh
# build_tar
