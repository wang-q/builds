#!/bin/bash

BASH_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd "${BASH_DIR}"/..

# Set the default OS type to 'linux'
OS_TYPE=${1:-linux}

# Validate the OS type
if [[ "$OS_TYPE" != "linux" && "$OS_TYPE" != "macos" ]]; then
    echo "Unsupported os_type: $OS_TYPE"
    echo "Supported os_type: linux, macos"
    exit 1
fi

# Set the target architecture based on the OS type
if [ "$OS_TYPE" == "linux" ]; then
    TARGET_ARCH="x86_64-linux-gnu.2.17"
elif [ "$OS_TYPE" == "macos" ]; then
    TARGET_ARCH="aarch64-macos-none"
fi

# Enter the spoa project directory
cd spoa

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT

# Copy source to temp directory
cp -R . ${TEMP_DIR}/
cd ${TEMP_DIR}

# Configure CMake with Zig compiler
ASM="zig cc" \
CC="zig cc" \
CXX="zig c++" \
CFLAGS="-I${BASH_DIR}/../static-${OS_TYPE}/include" \
LDFLAGS="-L${BASH_DIR}/../static-${OS_TYPE}/lib" \
cmake \
    -DCMAKE_ASM_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_C_COMPILER_TARGET="${TARGET_ARCH}" \
    -DCMAKE_CXX_COMPILER_TARGET="${TARGET_ARCH}" \
    -DZLIB_INCLUDE_DIR="${BASH_DIR}/../static-${OS_TYPE}/include" \
    -DZLIB_LIBRARY="${BASH_DIR}/../static-${OS_TYPE}/lib/libz.a" \
    -Dspoa_build_executable=ON \
    -Dspoa_optimize_for_portability=ON \
    -S . -B build

# Build the project
cmake --build build

if [ $? -eq 0 ]; then
    echo "Build successful"
else
    echo "Build failed"
    exit 1
fi  

BINS="spoa"

# Define the name of the compressed file
FN_TAR="spoa.${OS_TYPE}.tar.gz"

# Create compressed archive with maximum compression
tar -cf - -C build/bin ${BINS} | gzip -9 > ${FN_TAR}

# Move archive to the central tar directory
mv ${FN_TAR} ${BASH_DIR}/../tar/
