#!/bin/bash

# Get the directory of the script
BASH_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Move to the parent directory of the script
cd "${BASH_DIR}"/..

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT

# Set download URL based on OS type
DL_URL="https://github.com/broadinstitute/picard/releases/download/3.3.0/picard.jar"

# Download and extract
curl -o ${TEMP_DIR}/picard.jar -L ${DL_URL} || { echo "Error: Failed to download"; exit 1; }
cd ${TEMP_DIR} || { echo "Error: Failed to enter temp directory"; exit 1; }

# Collect binaries and scripts
mkdir -p collect/libexec/
cp picard.jar collect/libexec/

# Create wrapper script
cat > collect/picard << 'EOF'
#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
exec java -jar "${SCRIPT_DIR}/libexec/picard.jar" "$@"
EOF

chmod +x collect/picard

# Define the name of the compressed file based on OS type
FN_TAR="picard.linux.tar.gz"

# Create compressed archive
cd  ${TEMP_DIR}/collect
tar -cf - * | gzip -9 > ${TEMP_DIR}/${FN_TAR}

# Move archive to the central tar directory
mv ${TEMP_DIR}/${FN_TAR} ${BASH_DIR}/../tar/

# Copy for macOS (instead of symlink for Windows compatibility)
cp ${BASH_DIR}/../tar/${FN_TAR} ${BASH_DIR}/../tar/picard.macos.tar.gz
