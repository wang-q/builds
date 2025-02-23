#!/bin/bash

# Get the directory of the script
BASH_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# Move to the parent directory of the script
cd "${BASH_DIR}"/..

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf ${TEMP_DIR}' EXIT

# Set download URL based on OS type
DL_URL="https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip"

# Download and extract
curl -o ${TEMP_DIR}/fastqc.zip -L ${DL_URL} || { echo "Error: Failed to download"; exit 1; }
cd ${TEMP_DIR} || { echo "Error: Failed to enter temp directory"; exit 1; }
unzip fastqc.zip

# Collect binaries and scripts
mkdir -p collect/libexec/fastqc
cp -R FastQC/* collect/libexec/fastqc

# Create wrapper script
cat > collect/fastqc << 'EOF'
#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
exec "${SCRIPT_DIR}/libexec/fastqc/fastqc" "$@"
EOF

chmod +x collect/libexec/fastqc/fastqc
chmod +x collect/fastqc

# Define the name of the compressed file based on OS type
FN_TAR="fastqc.linux.tar.gz"

# Create compressed archive
cd  ${TEMP_DIR}/collect
tar -cf - * | gzip -9 > ${TEMP_DIR}/${FN_TAR}

# Move archive to the central tar directory
mv ${TEMP_DIR}/${FN_TAR} ${BASH_DIR}/../tar/

# Copy for macOS (instead of symlink for Windows compatibility)
cp ${BASH_DIR}/../tar/${FN_TAR} ${BASH_DIR}/../tar/fastqc.macos.tar.gz
