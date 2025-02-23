#!/bin/bash

# Get the directory of the script and project name
BASH_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PROJ=$(basename "${BASH_SOURCE[0]}" .sh)

# Move to the parent directory of the script
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

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT

# Copy source to temp directory
cp src/${PROJ}.tar.gz ${TEMP_DIR}/

# Extract the source code
cd ${TEMP_DIR}
echo "Extracting ${PROJ}.tar.gz..."
tar xvfz ${PROJ}.tar.gz || { echo "Error: Failed to extract source"; exit 1; }

cd ${PROJ} 2>/dev/null ||
    cd ${PROJ}-* 2>/dev/null ||
    { echo "Error: Cannot find source directory"; exit 1; }

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
