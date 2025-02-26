#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# Build with the specified target architecture
make \
    CC="zig cc -target ${TARGET_ARCH}" \
    AR="zig ar" \
    RANLIB="zig ranlib" \
    || exit 1

# Install to collect directory
make install PREFIX="${TEMP_DIR}/collect"

# Clean up and reorganize
cd "${TEMP_DIR}/collect/bin"
ln -sf bzdiff bzcmp
ln -sf bzgrep bzegrep
ln -sf bzgrep bzfgrep
ln -sf bzmore bzless

mv "${TEMP_DIR}/collect/bin"/* "${TEMP_DIR}/collect/"
rm -rf "${TEMP_DIR}/collect/bin"
rm -rf "${TEMP_DIR}/collect/man"

# tree "${TEMP_DIR}/collect"

# Use build_tar function from common.sh
build_tar
