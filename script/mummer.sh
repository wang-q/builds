#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# Build mummer with the specified target architecture
CC="zig cc -target ${TARGET_ARCH}" \
CXX="zig c++ -target ${TARGET_ARCH}" \
    ./configure \
    --prefix="${TEMP_DIR}/collect" \
    --bindir="${TEMP_DIR}/collect" \
    --disable-dependency-tracking \
    --disable-silent-rules \
    || exit 1
make -j 8 || exit 1
make install || exit 1

# Fix shebang lines in all files
find "${TEMP_DIR}/collect" -type f -print0 |
while IFS= read -r -d '' file; do
    fix_shebang "$file"
done

# Rename binary
mv ${TEMP_DIR}/collect/annotate ${TEMP_DIR}/collect/annotate-mummer

# Use build_tar function from common.sh
build_tar
