#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# Configure CMake with Zig compiler
./bootstrap.sh \
    --with-toolset=gcc \
    --without-icu \
    --without-libraries=python,mpi,log

# ./b2 --help

./b2 headers

./b2 \
    --prefix="${TEMP_DIR}/collect" \
    --libdir="${TEMP_DIR}/collect/lib" \
    -d2 \
    -j8 \
    --layout=system \
    threading=multi \
    link=static \
    cxxflags=-std=c++11 \
    install

ls -l "${TEMP_DIR}/collect/lib"

# cmake -LH .

# # Configure CMake with Zig compiler
# cmake \
#     -DCMAKE_INSTALL_PREFIX="${TEMP_DIR}/collect" \
#     -DBOOST_EXCLUDE_LIBRARIES=python,mpi,log,charconv,context \
#     -DBOOST_ENABLE_PYTHON=OFF \
#     -DBOOST_ENABLE_MPI=OFF \
#     -DBOOST_IOSTREAMS_ENABLE_BZIP2=OFF \
#     -DBOOST_IOSTREAMS_ENABLE_LZMA=OFF \
#     -DBOOST_IOSTREAMS_ENABLE_ZSTD=OFF \
#     -DBUILD_TESTING=OFF \
#     -S . -B build

#     # -DBOOST_LOCALE_ENABLE_ICU=OFF \

# # Build the project
# cmake --build build -- -j 8 || exit 1

# # # Use build_tar function from common.sh
# # build_tar
