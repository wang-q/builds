#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Build the project with the specified target architecture and flags
make \
    CC="zig cc -target ${TARGET_ARCH} -D_GNU_SOURCE" \
    || exit 1

# Get binary names from Makefile
BINS=$(cat Makefile | grep "^ALL = " | sed 's/^ALL =//')

# Create collect directory and copy binaries
mkdir -p ${TEMP_DIR}/collect
cp ${BINS} ${TEMP_DIR}/collect/

# Use build_tar function from common.sh
build_tar
