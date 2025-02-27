#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Extract source code
extract_source

# ./bootstrap.sh --show-libraries

./bootstrap.sh \
    --with-toolset=gcc \
    --without-icu \
    --without-libraries=python,mpi,log

# ./b2 --help

# ./b2 headers

./b2 \
    --prefix="${TEMP_DIR}/collect" \
    --libdir="${TEMP_DIR}/collect/lib" \
    -d2 \
    -j8 \
    --layout=system \
    threading=multi \
    link=static \
    cxxflags=-std=c++11 \
    -sNO_BZIP2=1 \
    -sNO_LZMA=1 \
    -sNO_ZSTD=1 \
    install

# test code
cat > test.cpp << 'EOF'
#include <iostream>
#include <boost/version.hpp>
#include <boost/algorithm/string.hpp>

int main() {
    std::string str = "hello,world";
    boost::to_upper(str);
    std::cout << "Boost version: " << BOOST_VERSION / 100000 << "."
              << BOOST_VERSION / 100 % 1000 << "."
              << BOOST_VERSION % 100 << "\n"
              << "Test string: " << str << "\n";
    return 0;
}
EOF

# compile and run test
g++ test.cpp -I"${TEMP_DIR}/collect/include" -L"${TEMP_DIR}/collect/lib" -lboost_system -o test
# g++ test.cpp -I"${HOME}/bin/include" -L"${HOME}/bin/lib" -lboost_system -o test
# zig c++ -target x86_64-linux-gnu.2.17 test.cpp -I"${HOME}/bin/include" -L"${HOME}/bin/lib" -lboost_system -o test -std=c++11
./test

ldd ./test

# Use build_tar function from common.sh
build_tar
