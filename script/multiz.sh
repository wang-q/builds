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

# Enter the multiz project directory
cd multiz || exit 1

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT

# Copy source to temp directory
cp -R . ${TEMP_DIR}/
cd ${TEMP_DIR}

# Build multiz with Zig cross-compiler and optimization flags
# Build the project with the specified target architecture and flags
make CC="zig cc -target ${TARGET_ARCH}" \
    CFLAGS="-I${BASH_DIR}/../static-${OS_TYPE}/include -L${BASH_DIR}/../static-${OS_TYPE}/lib -O3 -Wall -Wextra -Wno-unused-result -fno-strict-aliasing" \
    || exit 1

# Get binary names from Makefile
BINS=$(make -p | grep "^all: " | sed 's/^all: //')

# Define archive name based on OS type
FN_TAR="multiz.${OS_TYPE}.tar.gz"

# Create compressed archive with maximum compression
tar -cf - ${BINS} | gzip -9 > ${FN_TAR}

# Move archive to the central tar directory
mv ${FN_TAR} ${BASH_DIR}/../tar/

# Commit the new archive
cd ${BASH_DIR}/..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"
