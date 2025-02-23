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

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT

# Set download URL based on OS type
if [ "$OS_TYPE" == "linux" ]; then
    DL_URL="https://github.com/marbl/Mash/releases/download/v2.3/mash-Linux64-v2.3.tar"
elif [ "$OS_TYPE" == "macos" ]; then
    DL_URL="https://github.com/marbl/Mash/releases/download/v2.3/mash-OSX64-v2.3.tar"
fi

# Download and extract
curl -o ${TEMP_DIR}/mash.tar -L ${DL_URL} || { echo "Error: Failed to download"; exit 1; }
cd ${TEMP_DIR} || { echo "Error: Failed to enter temp directory"; exit 1; }
tar xvf mash.tar

# Collect binaries and scripts
mkdir collect
cp mash-*/mash collect/

# Define the name of the compressed file based on OS type
FN_TAR="mash.${OS_TYPE}.tar.gz"

# Create compressed archive
cd collect
tar -cf - * | gzip -9 > ${TEMP_DIR}/${FN_TAR}

# Move archive to the central tar directory
mv ${TEMP_DIR}/${FN_TAR} ${BASH_DIR}/../tar/
