#!/bin/bash

# Get the directory of the script
BASH_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

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

# Enter the trf directory
cd trf || exit 1

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT

# Copy source to temp directory
cp trf.src.tar.gz ${TEMP_DIR}/
cd ${TEMP_DIR}

# Extract the TRF source code
tar xvfz trf.src.tar.gz || exit 1

# Build TRF with the specified target architecture
cd TRF-* || exit 1
CC="zig cc -target ${TARGET_ARCH}" ./configure || exit 1
make || exit 1

# Define the name of the compressed file based on OS type
FN_TAR="trf.${OS_TYPE}.tar.gz"

# Create compressed archive
tar -cf - -C src trf | gzip -9 > ${FN_TAR}

# Move archive to the central tar directory
mv ${FN_TAR} ${BASH_DIR}/../tar/
