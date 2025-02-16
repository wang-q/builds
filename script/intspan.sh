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
    TARGET_ARCH="x86_64-unknown-linux-gnu.2.17"
elif [ "$OS_TYPE" == "macos" ]; then
    TARGET_ARCH="aarch64-apple-darwin"
fi

# Create a directory for cargo build artifacts
mkdir -p /tmp/cargo
export CARGO_TARGET_DIR=/tmp/cargo

# Enter the intspan project directory
cd intspan

# Build the project with the specified target architecture
cargo zigbuild --target ${TARGET_ARCH} --release

# List the contents of the release directory
ll $CARGO_TARGET_DIR/${TARGET_ARCH}/release/

# Extract the names of binary targets from Cargo.toml
BINS=$(
    cargo read-manifest |
        jq --raw-output '.targets[] | select( .kind[0] == "bin" ) | .name '
)

# Copy the built binaries to the current directory
for BIN in $BINS; do
    cp $CARGO_TARGET_DIR/${TARGET_ARCH}/release/$BIN .
done

# Define the name of the compressed file
FN_TAR="intspan.${OS_TYPE}.tar.gz"

# Package the binaries into a compressed file
GZIP=-9 tar cvfz ${FN_TAR} \
    $BINS

# Move the compressed file to the tar directory
mv ${FN_TAR} ../tar/

# Clean up the copied binaries
rm $BINS

# Return to the parent directory and commit the compressed file to the Git repository
cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"
