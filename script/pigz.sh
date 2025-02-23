#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Build the project with the specified target architecture and flags
make pigz \
    -j 8 \
    CC="zig cc -target ${TARGET_ARCH}" \
    CFLAGS="-I$HOME/bin/include -O3 -Wall -Wextra -Wno-unknown-pragmas -Wcast-qual" \
    LDFLAGS="-L$HOME/bin/lib" \
    || exit 1

# Collect binaries and create tarball
collect_bins pigz
build_tar
