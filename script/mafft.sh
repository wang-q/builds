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

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT

# Copy source to temp directory
cp src/mafft.tar.gz ${TEMP_DIR}/

# Extract the source code
cd ${TEMP_DIR}
tar xvfz mafft.tar.gz || exit 1

# Build the project with the specified target architecture and flags
cd mafft-* || exit 1
make \
    -j 8 \
    -C core \
    install \
    CC="zig cc -target ${TARGET_ARCH}" \
    CXX="zig c++ -target ${TARGET_ARCH}" \
    PREFIX="${TEMP_DIR}/build" \
    || exit 1
make \
    -j 8 \
    -C extensions \
    install \
    CC="zig cc -target ${TARGET_ARCH}" \
    CXX="zig c++ -target ${TARGET_ARCH}" \
    PREFIX="${TEMP_DIR}/build" \
    || exit 1

tree ${TEMP_DIR}/build

# # Get binary names from Makefile
# BINS=$(make -p | grep "^all: " | sed 's/^all: //')

# # Define archive name based on OS type
# FN_TAR="mafft.${OS_TYPE}.tar.gz"

# # Create compressed archive with maximum compression
# tar -cf - ${BINS} | gzip -9 > ${FN_TAR}

# # Move archive to the central tar directory
# mv ${FN_TAR} ${BASH_DIR}/../tar/
