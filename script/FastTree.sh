#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# Build the project with the specified target architecture and flags
zig cc -target ${TARGET_ARCH} \
    -O3 \
    -finline-functions \
    -funroll-loops \
    -DUSE_DOUBLE \
    -lm \
    FastTree.c \
    -o FastTree ||
    exit 1

# ldd FastTree

# ./FastTree

    # -static \
    # -fopenmp=libomp \
    # -DOPENMP \
    # -I$HOME/bin/include \
    # -L$HOME/bin/lib \
    # -lomp \

# Collect binaries and create tarball
collect_bins FastTree
build_tar
