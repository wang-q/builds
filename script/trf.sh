#!/bin/bash

# Get the directory of the script
BASH_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Move to the parent directory of the script
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

# Enter the trf directory
cd trf

# Extract the TRF source code
tar xvfz trf.src.tar.gz

# Build TRF with the specified target architecture
cd TRF-*
CC="zig cc -target ${TARGET_ARCH}" ./configure
make

# Move the compiled binary to the parent directory
mv src/trf ../
cd ..

# Define the name of the compressed file (strip .2.17 from TARGET_ARCH if present)
FN_TAR="trf.${TARGET_ARCH%.2.17}.tar.gz"

# Package the build results
GZIP=-9 tar cvfz ${FN_TAR} \
    trf

# Move the compressed file to the tar directory
mv ${FN_TAR} ../tar/

# Clean up the TRF source directory
rm trf
rm -fr TRF-*

# Return to the parent directory and commit the compressed file to the Git repository
cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"
