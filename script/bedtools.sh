#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# Create necessary directories
mkdir -p obj bin

# Build the project with the specified target architecture and flags
make \
    CC_WRAPPER="" \
    CXX="zig c++ -target ${TARGET_ARCH}" \
    CXXFLAGS="-I$HOME/bin/include -L$HOME/bin/lib" \
    LDFLAGS="-L$HOME/bin/lib" \
    LIBS="-lz -lm -lbz2 -llzma -lpthread" \
    || exit 1

tree .

# # Collect binaries and create tarball
# collect_make_bins
# build_tar
