#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Get libomp path from brew
LIBOMP_PATH=$(brew --prefix libomp)

# Create directories
mkdir -p "${TEMP_DIR}/collect/include"
mkdir -p "${TEMP_DIR}/collect/lib"

# Copy files
cp -R "${LIBOMP_PATH}/include/"* "${TEMP_DIR}/collect/include/"
cp -R "${LIBOMP_PATH}/lib/"* "${TEMP_DIR}/collect/lib/"

# Remove .so files
find "${TEMP_DIR}/collect/lib/" -name "*.so*" -delete
find "${TEMP_DIR}/collect/lib/" -name "*.dylib*" -delete

# tree "${TEMP_DIR}/collect"

# Use build_tar function from common.sh
build_tar
