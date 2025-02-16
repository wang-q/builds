#!/bin/bash

BASH_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd "${BASH_DIR}"/..

# Set the default OS type to 'linux'
OS_TYPE=${1:-linux}

# Validate the OS type
if [[ "$OS_TYPE" != "linux" && "$OS_TYPE" != "macos" ]]; then
    echo "Unsupported os_type: $OS_TYPE"
    echo "Supported os_type: linux, macos"
    exit 1
fi

# Set the target architecture based on the OS type
if [ "$OS_TYPE" == "linux" ]; then
    TARGET_ARCH="x86_64-linux-gnu.2.17"
elif [ "$OS_TYPE" == "macos" ]; then
    TARGET_ARCH="aarch64-macos-none"
fi

# Create a directory for static libraries
mkdir -p static

# Download and extract zlib
curl -L https://zlib.net/zlib-1.3.1.tar.gz | tar xvz

# Build zlib with the specified target architecture
cd zlib-1.3.1
CC="zig cc -target ${TARGET_ARCH}" ./configure --static --prefix=../static
make
make install
cd ..

# Clean up the zlib source directory
rm -fr zlib-1.3.1

# Enter the MERQURY.FK project directory
cd MERQURY.FK

# Restore the Git repository to its original state
git restore .

# Clean the build environment
make clean

# Modify the Makefile to use zig cc and specify the target architecture
sed -i 's/^\t\s*gcc/\t$(CC)/g' Makefile
sed -i "s|^CFLAGS =.*$|CFLAGS = -I../static/include -L../static/lib -O3 -Wall -Wextra -Wno-unused-result -fno-strict-aliasing|g" Makefile
sed -i "1i CC = zig cc -target ${TARGET_ARCH}" Makefile

# Build the project
make

# Define the name of the compressed file
FN_TAR="MERQURY.FK.${OS_TYPE}.tar.gz"

# Package the build results
GZIP=-9 tar cvfz ${FN_TAR} \
    $(make -p | grep "^all: " | sed 's/^all://')

# Move the compressed file to the tar directory
mv ${FN_TAR} ../tar/

# Restore the Git repository and clean the build environment
git restore .
make clean

# Return to the parent directory and commit the compressed file to the Git repository
cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"
