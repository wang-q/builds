#!/bin/bash

# Create target directory if it doesn't exist
mkdir -p $HOME/bin

# Detect platform
if [[ "$(uname)" == "Darwin" ]]; then
    OS_TYPE="macos"
else
    OS_TYPE="linux"
fi

# Get package names from command line arguments
PACKAGES=()
if [ $# -eq 0 ]; then
    # Install all packages if no arguments provided
    PACKAGES=("tar/*${OS_TYPE}*")
else
    # Convert package names to tar path patterns
    for pkg in "$@"; do
        PACKAGES+=("tar/${pkg}.${OS_TYPE}.*tar.gz")
    done
fi

# Download and install all binary packages
curl -fsSL https://api.github.com/repos/wang-q/builds/git/trees/master?recursive=1 |
    jq -r '.tree[] | select( .path | startswith("tar/") ) | .path' |
    while read -r path; do
        # 检查是否是请求安装的包
        if [ ${#PACKAGES[@]} -gt 0 ]; then
            MATCH=0
            for pattern in "${PACKAGES[@]}"; do
                if [[ $path == $pattern ]]; then
                    MATCH=1
                    break
                fi
            done
            [ $MATCH -eq 0 ] && continue
        fi

        echo "==> Installing ${path}"
        
        # Create temp file
        TEMP_FILE=$(mktemp)
        
        # Download to temp file
        curl -fsSL "https://raw.githubusercontent.com/wang-q/builds/master/${path}" \
            -o "${TEMP_FILE}"
        
        if [ $? -eq 0 ]; then
            # Extract from temp file
            tar xzf "${TEMP_FILE}" --directory=$HOME/bin/
            
            if [ $? -eq 0 ]; then
                echo "    Done"
            else
                echo "    Failed to extract ${path}"
                rm -f "${TEMP_FILE}"
                exit 1
            fi
        else
            echo "    Failed to download ${path}"
            rm -f "${TEMP_FILE}"
            exit 1
        fi
        
        # Clean up temp file
        rm -f "${TEMP_FILE}"
    done
    