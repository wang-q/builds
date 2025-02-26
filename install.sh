#!/bin/bash

# Create target directory if it doesn't exist
mkdir -p $HOME/bin

# Function definitions
show_help() {
    echo "Usage: $0 [options] [package1 package2 ...]"
    echo
    echo "Options:"
    echo "  -h, --help  Show this help message"
    echo "  -a          List all available packages"
    echo "  -l          List installed packages"
    echo "  -r, -u      Remove installed packages"
    echo "  --linux     List packages for Linux"
    echo "  --macos     List packages for macOS"
    echo
    echo "Examples:"
    echo "  bash $0 -l              # List installed packages"
    echo "  bash $0 -a              # List all available packages"
    echo "  bash $0 pigz minimap2   # Install specified packages"
    echo "  bash $0 -r pigz         # Remove specified packages"
    echo
    echo "Dev options:"
    echo "  -f          List foreign files in ~/bin"
    echo "  -b          List unbuilt packages"
    echo "  --dep       Check dynamic dependencies"
}

# Detect platform
if [[ "$(uname)" == "Darwin" ]]; then
    OS_TYPE="macos"
else
    OS_TYPE="linux"
fi

# Define perl format script for package listing
PERL_FMT='
    BEGIN{
        $p="";
        $count=0;
        $width=80;
    }
    chomp;
    $c = substr($_, 0, 1);
    if ($p ne "" and $c ne $p) {
        print "\n";
        $count = 0;
    }
    if ($count > 0 and $count * 16 + 16 > $width) {
        print "\n";
        $count = 0;
    }
    $p = $c;
    printf "  %-14s", $_;
    $count++;
'

list_packages() {
    local pattern="$1"
    local message="$2"
    echo "==> ${message}"
    curl -fsSL https://api.github.com/repos/wang-q/builds/git/trees/master?recursive=1 |
        jq -r '.tree[] | select(.path | startswith("tar/")) | .path' |
        grep "${pattern}" |
        sed 's/^tar\///' |
        sed "s/${pattern}//" |
        sort |
        perl -n -e "${PERL_FMT}"
    echo
}

list_available() {
    list_packages "\.${OS_TYPE}\.tar\.gz$" "Available packages for ${OS_TYPE}"
}

list_installed() {
    if [ $# -eq 0 ]; then
        echo "==> Installed packages:"
        if [ -d "$HOME/bin/.builds" ]; then
            find "$HOME/bin/.builds" -name "*.files" -printf "%f\n" |
                sed 's/\.files$//' |
                sort |
                perl -n -e "${PERL_FMT}"
        fi
        echo
    else
        for pkg in "$@"; do
            if [ -f "$HOME/bin/.builds/${pkg}.files" ]; then
                echo "==> Files in package ${pkg}:"
                cat "$HOME/bin/.builds/${pkg}.files"
                echo
            else
                echo "Warning: Package ${pkg} is not installed"
            fi
        done
    fi
}

list_unbuilt() {
    echo "==> Packages in script/ but not built for ${OS_TYPE}:"
    comm -23 \
        <(find script/ -name "*.sh" ! -name "common.sh" ! -name "rust.sh" -printf "%f\n" | sed 's/\.sh$//' | sort) \
        <(curl -fsSL https://api.github.com/repos/wang-q/builds/git/trees/master?recursive=1 |
            jq -r '.tree[] | select(.path | startswith("tar/")) | .path' |
            grep "\.${OS_TYPE}\.tar\.gz$" |
            sed 's/^tar\///' |
            sed "s/\.${OS_TYPE}\.tar\.gz$//" |
            sort) |
        perl -n -e "${PERL_FMT}"
    echo
}

list_linux() {
    list_packages "\.linux\.tar\.gz$" "Available packages for Linux"
}

list_macos() {
    list_packages "\.macos\.tar\.gz$" "Available packages for macOS"
}

list_foreign() {
    echo "==> Foreign files in $HOME/bin:"
    # Create temp file to store known files
    local temp_known=$(mktemp)
    trap 'rm -f ${temp_known}' EXIT

    # Collect files from installed packages
    if [ -d "$HOME/bin/.builds" ]; then
        cat "$HOME/bin/.builds"/*.files > "${temp_known}" 2>/dev/null
    fi

    # Find and display files not in known list, excluding .builds directory
    find "$HOME/bin" -type f -not -path "$HOME/bin/.builds/*" -printf "%P\n" | sort | \
    while read -r file; do
        if ! grep -Fxq "$file" "${temp_known}"; then
            echo "  $file"
        fi
    done
    echo
}

remove_packages() {
    for pkg in "$@"; do
        if [ -f "$HOME/bin/.builds/${pkg}.files" ]; then
            echo "==> Removing ${pkg}"
            xargs rm -f < "$HOME/bin/.builds/${pkg}.files"
            rm -f "$HOME/bin/.builds/${pkg}.files"
            echo "    Done"
        else
            echo "Warning: Package ${pkg} is not installed"
        fi
    done
}

install_package() {
    local pkg_path="$1"
    local pkg_name=$(basename "${pkg_path}" ".${OS_TYPE}.tar.gz")
    local install_dir="$HOME/bin"
    local record_dir="$HOME/bin/.builds"

    echo "==> Installing ${pkg_path}"

    mkdir -p "${record_dir}"

    tar tzf "${pkg_path}" > "${record_dir}/${pkg_name}.files" || {
        echo "    Failed to list files in ${pkg_path}"
        return 1
    }

    tar xzf "${pkg_path}" --directory="${install_dir}" || {
        echo "    Failed to extract ${pkg_path}"
        rm -f "${record_dir}/${pkg_name}.files"
        return 1
    }

    echo "    Done"
    return 0
}

install_remote_package() {
    local pkg_path="$1"
    local temp_file="$2"

    echo "==> Installing remote ${pkg_path}"

    if ! curl -fsSL "https://raw.githubusercontent.com/wang-q/builds/master/${pkg_path}" -o "${temp_file}"; then
        echo "    Failed to download ${pkg_path}"
        return 1
    fi

    if ! install_package "${temp_file}"; then
        return 1
    fi

    return 0
}

check_dependencies() {
    local pkg="$1"
    local record_dir="$HOME/bin/.builds"

    if [ ! -f "${record_dir}/${pkg}.files" ]; then
        echo "Warning: Package ${pkg} is not installed"
        return 1
    fi

    echo "==> Dependencies for package ${pkg}:"
    while read -r file; do
        local full_path="$HOME/bin/$file"
        # skip symlinks
        if [ -L "$full_path" ]; then
            continue
        fi

        if [ -f "$full_path" ] && [ -x "$full_path" ]; then
            # skip text files
            if file "$full_path" | grep -q "text"; then
                continue
            fi

            echo "  File: $file"
            if command -v ldd >/dev/null 2>&1; then
                # Store ldd output in a variable
                local ldd_out=$(ldd "$full_path" 2>&1)
                if [[ $ldd_out == *"not a dynamic executable"* ]]; then
                    echo "    Static executable"
                else
                    local deps=$(
                        echo "$ldd_out" |
                            grep -v -E 'linux-vdso|ld-linux' |
                            grep -v -E 'libc.so|libpthread|libdl.so' |
                            grep -v -E 'libm.so|libgcc_s.so|libstdc\+\+'
                        )
                    if [ -n "$deps" ]; then
                        echo "$deps" | sed 's/^/    /'
                    else
                        echo "    No additional dependencies"
                    fi
                fi
            else
                echo "    Warning: ldd not found"
            fi
            echo
        fi
    done < "${record_dir}/${pkg}.files"
}

# Process command line options
while getopts "habflr:u:-:" opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        a)
            list_available
            exit 0
            ;;
        b)
            list_unbuilt
            exit 0
            ;;
        l)
            shift $((OPTIND-1))
            if [ $# -eq 0 ]; then
                list_installed
            else
                list_installed "$1"
            fi
            exit 0
            ;;
        f)
            list_foreign
            exit 0
            ;;
        r|u)
            if [ $# -lt 2 ]; then
                echo "Error: Please specify package(s) to remove"
                exit 1
            fi
            shift
            remove_packages "$@"
            exit 0
            ;;
        -)
            case "${OPTARG}" in
                help)
                    show_help
                    exit 0
                    ;;
                linux)
                    list_linux
                    exit 0
                    ;;
                macos)
                    list_macos
                    exit 0
                    ;;
                dep)
                    if [ $# -lt 2 ]; then
                        echo "Error: Please specify package(s) to check"
                        exit 1
                    fi
                    shift
                    for pkg in "$@"; do
                        check_dependencies "$pkg"
                    done
                    exit 0
                    ;;
                *)
                    echo "Invalid option: --${OPTARG}"
                    exit 1
                    ;;
            esac
            ;;
        ?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

# Show help if no arguments provided
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Install packages
REMOTE_PKGS=()
FOUND_PKGS=()

# Process local packages first
for pkg in "$@"; do
    pkg_path="tar/${pkg}.${OS_TYPE}.tar.gz"
    if [ -f "${pkg_path}" ]; then
        install_package "${pkg_path}" || exit 1
    else
        REMOTE_PKGS+=("${pkg_path}")
    fi
done

# Exit if no remote packages need to be installed
[ ${#REMOTE_PKGS[@]} -eq 0 ] && exit 0

# Create temp file and ensure cleanup
TEMP_FILE=$(mktemp)
trap 'rm -f ${TEMP_FILE}' EXIT

# Process remote packages
curl -fsSL https://api.github.com/repos/wang-q/builds/git/trees/master?recursive=1 |
    jq -r '.tree[] | select(.path | startswith("tar/")) | .path' |
    while read -r path; do
        for pattern in "${REMOTE_PKGS[@]}"; do
            if [[ $path == $pattern ]]; then
                FOUND_PKGS+=("$pattern")
                install_remote_package "${path}" "${TEMP_FILE}" || continue
                break
            fi
        done
    done

# Check for packages not found
for pkg in "${REMOTE_PKGS[@]}"; do
    if [[ ! " ${FOUND_PKGS[@]} " =~ " ${pkg} " ]]; then
        echo "Warning: Package not found in remote repository: ${pkg}"
    fi
done
