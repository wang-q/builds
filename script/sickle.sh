#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Build the project with the specified target architecture and flags
make \
    -j 8 \
    CC="zig cc -target ${TARGET_ARCH}" \
    AR="zig ar" \
    CFLAGS="-I$HOME/bin/include -Wall -pedantic -DVERSION=1.33" \
    LDFLAGS="-L$HOME/bin/lib" \
    || exit 1

# Collect binaries and create tarball
collect_bins sickle
build_tar
