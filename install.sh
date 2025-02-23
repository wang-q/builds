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
REMOTE_PKGS=()
if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 package1 [package2 ...]"
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  -l           List packages for Linux"
    echo "  -m           List packages for macOS"
    echo
    echo "Examples:"
    echo "  bash $0 pigz    # Install specified packages"
    exit 1
elif [ "$1" == "-l" ]; then
    echo "==> Available packages for Linux:"
    curl -fsSL https://api.github.com/repos/wang-q/builds/git/trees/master?recursive=1 |
        jq -r '.tree[] | select(.path | startswith("tar/")) | .path' |
        grep "\.linux\.tar\.gz$" |
        sed 's/^tar\///' |
        sed 's/\.linux\.tar\.gz$//' |
        sort |
        perl -n -e '
            BEGIN{$p=""}
            chomp;
            $c = substr($_, 0, 1);
            print "\n" if $p ne "" and $c ne $p;
            $p=$c;
            printf "    %-8s", $_;
            '
    echo
    exit 0
elif [ "$1" == "-m" ]; then
    echo "==> Available packages for macOS:"
    curl -fsSL https://api.github.com/repos/wang-q/builds/git/trees/master?recursive=1 |
        jq -r '.tree[] | select(.path | startswith("tar/")) | .path' |
        grep "\.macos\.tar\.gz$" |
        sed 's/^tar\///' |
        sed 's/\.macos\.tar\.gz$//' |
        sort |
        perl -n -e '
            BEGIN{$p=""}
            chomp;
            $c = substr($_, 0, 1);
            print "\n" if $p ne "" and $c ne $p;
            $p=$c;
            printf "    %-8s", $_;
            '
    echo
    exit 0
fi

# Convert package names to tar path patterns
for pkg in "$@"; do
    pkg_path="tar/${pkg}.${OS_TYPE}.tar.gz"
    # Check if local package exists
    if [ -f "${pkg_path}" ]; then
        echo "==> Installing local ${pkg_path}"
        tar xzf "${pkg_path}" --directory=$HOME/bin/ ||
            { echo "    Failed to extract ${pkg_path}"; exit 1; }
        echo "    Done"
    else
        REMOTE_PKGS+=("${pkg_path}")
    fi
done

# Exit if no remote packages need to be installed
[ ${#REMOTE_PKGS[@]} -eq 0 ] && exit 0

# Create temp file and ensure cleanup
TEMP_FILE=$(mktemp)
trap 'rm -f ${TEMP_FILE}' EXIT

# Download and install remote binary packages
FOUND_PKGS=()
curl -fsSL https://api.github.com/repos/wang-q/builds/git/trees/master?recursive=1 |
    jq -r '.tree[] | select( .path | startswith("tar/") ) | .path' |
    while read -r path; do
        # Check if package is in remote list
        MATCH=0
        for pattern in "${REMOTE_PKGS[@]}"; do
            if [[ $path == $pattern ]]; then
                MATCH=1
                FOUND_PKGS+=("$pattern")
                break
            fi
        done
        [ $MATCH -eq 0 ] && continue

        echo "==> Installing remote ${path}"

        # Download to temp file
        if ! curl -fsSL "https://raw.githubusercontent.com/wang-q/builds/master/${path}" -o "${TEMP_FILE}"; then
            echo "    Failed to download ${path}"
            continue
        fi

        # Extract from temp file
        if ! tar xzf "${TEMP_FILE}" --directory=$HOME/bin/; then
            echo "    Failed to extract ${path}"
            continue
        fi

        echo "    Done"
    done

# Check for packages not found
for pkg in "${REMOTE_PKGS[@]}"; do
    if [[ ! " ${FOUND_PKGS[@]} " =~ " ${pkg} " ]]; then
        echo "Warning: Package not found in remote repository: ${pkg}"
    fi
done
