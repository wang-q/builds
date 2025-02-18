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

# Enter the MERQURY.FK project directory
cd MERQURY.FK || exit 1

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT

# Copy source to temp directory
cp -R . ${TEMP_DIR}/
cd ${TEMP_DIR}

# Modify the Makefile to use zig cc and specify the target architecture
sed -i 's/^\t\s*gcc/\t$(CC)/g' Makefile || exit 1
sed -i "s|^CFLAGS =.*$|CFLAGS = -I${BASH_DIR}/../static-${OS_TYPE}/include -L${BASH_DIR}/../static-${OS_TYPE}/lib -O3 -Wall -Wextra -Wno-unused-result -fno-strict-aliasing|g" Makefile || exit 1
sed -i "1i CC = zig cc -target ${TARGET_ARCH}" Makefile || exit 1

# Build the project
make || exit 1

# Get binary names from Makefile
BINS=$(make -p | grep "^all: " | sed 's/^all: //')

# Define archive name based on OS type
FN_TAR="MERQURY.FK.${OS_TYPE}.tar.gz"

# Create compressed archive with maximum compression
tar -cf - ${BINS} | gzip -9 > ${FN_TAR}

# Move archive to the central tar directory
mv ${FN_TAR} ${BASH_DIR}/../tar/
