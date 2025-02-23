#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Build the project with the specified target architecture and flags
make \
    CC="zig cc -target ${TARGET_ARCH}" \
    CFLAGS="-I$HOME/bin/include -L$HOME/bin/lib -O3 -Wall -Wextra -Wno-unused-result -fno-strict-aliasing -fcommon" \
    || exit 1

# Collect binaries and create tarball
collect_make_bins
build_tar
