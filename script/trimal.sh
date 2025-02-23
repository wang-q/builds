#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Build with the specified target architecture
make \
    -C source \
    || exit 1

# Collect binaries and create tarball
collect_bins source/trimal source/readal source/statal
build_tar
