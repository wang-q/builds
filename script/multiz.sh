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

# Restore the Git repository to its original state
git restore . || exit 1

# Clean the build environment
make clean

# Build multiz with Zig cross-compiler and optimization flags
make CC="zig cc -target ${TARGET_ARCH}" \
    CFLAGS="-I../static/include -L../static/lib -O3 -Wall -Wextra -Wno-unused-result -fno-strict-aliasing -fcommon" \
    || exit 1

# Get binary names from Makefile
BINS=$(make -p | grep "^all: " | sed 's/^all: //')

# Define archive name based on OS type
FN_TAR="multiz.${OS_TYPE}.tar.gz"

# Create compressed archive with maximum compression
tar -cf - ${BINS} | gzip -9 > ${FN_TAR}

# Move archive to the central tar directory
mv ${FN_TAR} ../tar/

# Clean up build environment
git restore .
make clean

# Commit the new archive
cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"
