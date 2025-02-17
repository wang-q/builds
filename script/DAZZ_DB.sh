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

# Enter the project directory
cd DAZZ_DB || exit 1

# Restore the Git repository to its original state
git restore . || exit 1

# Clean the build environment
make clean

# Modify the Makefile to use zig cc and specify the target architecture
sed -i 's/^\t\s*gcc/\t$(CC)/g' Makefile || exit 1
sed -i "1i CC = zig cc -target ${TARGET_ARCH}" Makefile || exit 1

# Remove specific targets from the Makefile
sed -i '/^quiva2DB:/{N;N;d;}' Makefile || exit 1
sed -i '/^DB2quiva:/{N;N;d;}' Makefile || exit 1
sed -i '/^arrow2DB:/{N;N;d;}' Makefile || exit 1
sed -i '/^DB2arrow:/{N;N;d;}' Makefile || exit 1

sed -i \
    -e 's/quiva2DB//g' \
    -e 's/DB2quiva//g' \
    -e 's/arrow2DB//g' \
    -e 's/DB2arrow//g' \
    Makefile || exit 1

# Build the project
make || exit 1

# Get binary names from Makefile
BINS=$(make -p | grep "^all: " | sed 's/^all: //')

# Define archive name based on OS type
FN_TAR="DAZZ_DB.${OS_TYPE}.tar.gz"

# Create compressed archive with maximum compression
tar -cf - ${BINS} | gzip -9 > ${FN_TAR}

# Move archive to the central tar directory
mv ${FN_TAR} ../tar/

# Clean up build environment
git restore .
make clean

# Commit the new archive
cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"
