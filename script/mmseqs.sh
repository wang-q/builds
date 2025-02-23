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
    DL_URL="https://github.com/soedinglab/MMseqs2/releases/download/17-b804f/mmseqs-linux-avx2.tar.gz"
elif [ "$OS_TYPE" == "macos" ]; then
    DL_URL="https://github.com/soedinglab/MMseqs2/releases/download/17-b804f/mmseqs-osx-universal.tar.gz"
fi

# Download and extract
curl -o ${TEMP_DIR}/mmseqs.tar.gz -L ${DL_URL}
cd ${TEMP_DIR}
tar xvfz mmseqs.tar.gz

# Collect binaries and scripts
mkdir collect
cp mmseqs/bin/* collect/

# Define the name of the compressed file based on OS type
FN_TAR="mmseqs.${OS_TYPE}.tar.gz"

# Create compressed archive
cd collect
tar -cf - * | gzip -9 > ${TEMP_DIR}/${FN_TAR}

# Move archive to the central tar directory
mv ${TEMP_DIR}/${FN_TAR} ${BASH_DIR}/../tar/
