#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

cmake -LH .

# Configure CMake with Zig compiler
ASM="zig cc" \
CC="zig cc" \
CXX="zig c++" \
CFLAGS="-I$HOME/bin/include" \
CXXFLAGS="-I$HOME/bin/include" \
LDFLAGS="-L$HOME/bin/lib" \
cmake \
    -DCMAKE_ASM_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_C_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_CXX_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_INCLUDE_PATH="$HOME/bin/include" \
    -DCMAKE_LIBRARY_PATH="$HOME/bin/lib" \
    -DZLIB_INCLUDE_DIR="$HOME/bin/include" \
    -DZLIB_LIBRARY="$HOME/bin/lib/libz.a" \
    -DCMAKE_C_FLAGS="-I$HOME/bin/include -Wno-unqualified-std-cast-call -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types -Wno-deprecated-builtins -Wno-deprecated-declarations" \
    -DCMAKE_CXX_FLAGS="-I$HOME/bin/include -Wno-unqualified-std-cast-call -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types -Wno-deprecated-builtins -Wno-deprecated-declarations" \
    -DKSIZE_LIST="32 64 96 128" \
    -DCMAKE_BUILD_TYPE=Release \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    -S . -B build

# Build the project
cmake --build build -- -j 8 || exit 1

# Collect binaries
collect_bins "build/bcalm"

# Use build_tar function from common.sh
build_tar
