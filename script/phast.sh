#!/bin/bash

# Source common build environment: extract source, setup dirs and functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Build the project with the specified target architecture and flags
sed -i 's/# vecLib on/ifdef NOTSKIPIT\n# vecLib on/g' src/make-include.mk || exit 1
sed -i 's/# bypassed altogether/endif/g' src/make-include.mk || exit 1

cd src
make \
    CC="zig cc -target ${TARGET_ARCH}" \
    || exit 1

# Define the name of the compressed file based on OS type
FN_TAR="${PROJ}.${OS_TYPE}.tar.gz"

# Create compressed archive
cd ../bin
tar -cf - * | gzip -9 > ${TEMP_DIR}/${FN_TAR}

# Move archive to the central tar directory
mv ${TEMP_DIR}/${FN_TAR} ${BASH_DIR}/../tar/
