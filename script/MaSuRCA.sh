#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# Set configure options based on OS type
export CC="zig cc -target ${TARGET_ARCH}"
export CXX="zig c++ -target ${TARGET_ARCH}"
export DEST="${TEMP_DIR}/collect"
export CFLAGS="-I${HOME}/bin/include -fcommon -Wno-format -Wno-implicit-function-declaration"
export CXXFLAGS="-I${HOME}/bin/include -fcommon -Wno-format -Wno-implicit-function-declaration"
export LDFLAGS="-L${HOME}/bin/lib"
export BOOST_ROOT="${HOME}/bin"
export BOOST_INCLUDEDIR="${HOME}/bin/include"
export BOOST_LIBRARYDIR="${HOME}/bin/lib"

# bash install.sh

cd global-1

# ./configure --help

# sed -i 's/m4_map_args_w(\[samtools /m4_map_args_w([/' configure.ac

# tail configure.ac

# ./autoreconf -if

./configure \
    --prefix="${TEMP_DIR}/collect" \
    --disable-swig \
    --disable-dependency-tracking \
    --disable-silent-rules \
    || exit 1
make -j 8 || exit 1
# make install || exit 1

# tree collect

# # Use build_tar function from common.sh
# build_tar
