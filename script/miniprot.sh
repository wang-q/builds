#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Build the project with the specified target architecture and flags
make \
    -j 8 \
    CC="zig cc -target ${TARGET_ARCH}" \
    CXX="zig c++ -target ${TARGET_ARCH}" \
    AR="zig ar" \
    CFLAGS="-I$HOME/bin/include -L$HOME/bin/lib -std=c99 -g -Wall -O3" \
    || exit 1

# ldd miniprot

# Collect binaries and create tarball
collect_bins miniprot
build_tar
