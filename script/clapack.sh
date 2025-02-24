#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# Build with the specified target architecture
ASM="zig cc" \
CC="zig cc" \
CXX="zig c++" \
cmake \
    -DCMAKE_ASM_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_C_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_CXX_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_C_FLAGS="-w -Wno-everything -fcommon" \
    -S . -B build

# Build the project
cmake --build build -- -j 8

if [ $? -eq 0 ]; then
    echo "Build successful"
else
    echo "Build failed"
    exit 1
fi

mkdir -p ${BASH_DIR}/../static-${OS_TYPE}/include
mkdir -p ${BASH_DIR}/../static-${OS_TYPE}/lib
cp INCLUDE/* ${BASH_DIR}/../static-${OS_TYPE}/include
cp build/F2CLIBS/libf2c/libf2c.a ${BASH_DIR}/../static-${OS_TYPE}/lib
cp build/BLAS/SRC/libblas.a ${BASH_DIR}/../static-${OS_TYPE}/lib
cp build/SRC/liblapack.a ${BASH_DIR}/../static-${OS_TYPE}/lib
