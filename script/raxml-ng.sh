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
    DL_URL="https://github.com/amkozlov/raxml-ng/releases/download/1.2.2/raxml-ng_v1.2.2_linux_x86_64.zip"
elif [ "$OS_TYPE" == "macos" ]; then
    DL_URL="https://github.com/amkozlov/raxml-ng/releases/download/1.2.2/raxml-ng_v1.2.2_macos.zip"
fi

# Download and extract raxml-ng
curl -o ${TEMP_DIR}/raxml-ng.zip -L ${DL_URL}
cd ${TEMP_DIR}
unzip raxml-ng.zip

# Define the name of the compressed file based on OS type
FN_TAR="raxml-ng.${OS_TYPE}.tar.gz"

# Create compressed archive
tar -cf - raxml-ng | gzip -9 > ${TEMP_DIR}/${FN_TAR}

# Move archive to the central tar directory
mv ${TEMP_DIR}/${FN_TAR} ${BASH_DIR}/../tar/
