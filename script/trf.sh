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
cd trf || exit 1

# Extract the TRF source code
tar xvfz trf.src.tar.gz || exit 1

# Build TRF with the specified target architecture
cd TRF-* || exit 1
CC="zig cc -target ${TARGET_ARCH}" ./configure || exit 1
make || exit 1

# Move the compiled binary to the parent directory
mv src/trf ../

# Move back to trf directory
cd ..

# Define the name of the compressed file based on OS type
FN_TAR="trf.${OS_TYPE}.tar.gz"

# Create compressed archive
tar --gzip --compress-level=9 -cvf ${FN_TAR} \
    trf

# Move archive to the central tar directory
mv ${FN_TAR} ../tar/

# Clean up build artifacts
rm trf
rm -fr TRF-*

# Return to project root and commit the new archive
cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"
