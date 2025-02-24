#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# Build the project with the specified target architecture and flags
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
