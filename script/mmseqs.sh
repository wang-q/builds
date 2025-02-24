#!/bin/bash

# Source common build environment
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Set download URL based on OS type
if [ "$OS_TYPE" == "linux" ]; then
    DL_URL="https://github.com/soedinglab/MMseqs2/releases/download/17-b804f/mmseqs-linux-avx2.tar.gz"
elif [ "$OS_TYPE" == "macos" ]; then
    DL_URL="https://github.com/soedinglab/MMseqs2/releases/download/17-b804f/mmseqs-osx-universal.tar.gz"
fi

# Download and extract
curl -L ${DL_URL} -o ${PROJ}.tar.gz ||
    { echo "Error: Failed to download ${PROJ}"; exit 1; }
tar xvfz ${PROJ}.tar.gz ||
    { echo "Error: Failed to extract ${PROJ}"; exit 1; }

# Collect binaries
mkdir collect
cp mmseqs/bin/* collect/

# Use build_tar function from common.sh
build_tar
