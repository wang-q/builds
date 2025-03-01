# Build binaries for glibc 2.17

[![License](https://img.shields.io/github/license/wang-q/builds)](https://github.com/wang-q/builds/blob/master/LICENSE)

A package manager for bioinformatics tools, focusing on glibc 2.17 (CentOS 7) compatibility and
Apple Silicon support. Pre-built binaries are cross-compiled with Zig for consistent builds across
platforms.

<!-- TOC -->
* [Build binaries for glibc 2.17](#build-binaries-for-glibc-217)
* [User Guide](#user-guide)
  * [System Requirements](#system-requirements)
  * [Installation](#installation)
  * [Available Commands](#available-commands)
  * [Package List](#package-list)
* [Developer Guide](#developer-guide)
  * [Project Design](#project-design)
  * [Build requirements](#build-requirements)
    * [Zig](#zig)
    * [git lfs](#git-lfs)
    * [Other tools](#other-tools)
    * [Rust](#rust)
  * [Source Management](#source-management)
    * [Source tarballs](#source-tarballs)
    * [Source codes from Git Repositories](#source-codes-from-git-repositories)
  * [Build Process](#build-process)
    * [Basic Libraries](#basic-libraries)
    * [`Makefile`](#makefile)
    * [`CLAPACK`](#clapack)
    * [`./configure`](#configure)
    * [`cmake`](#cmake)
    * [Projects requiring specific build environments](#projects-requiring-specific-build-environments)
    * [Rust projects](#rust-projects)
  * [Binary tarballs](#binary-tarballs)
  * [Dynamic Library Dependencies](#dynamic-library-dependencies)
  * [License](#license)
* [FAQ](#faq)
  * [Why use Zig for cross-compilation?](#why-use-zig-for-cross-compilation)
  * [How does this compare to Conda/Bioconda?](#how-does-this-compare-to-condabioconda)
  * [Can I use these binaries in a Docker container?](#can-i-use-these-binaries-in-a-docker-container)
  * [How do I request a new package?](#how-do-i-request-a-new-package)
<!-- TOC -->

# User Guide

## System Requirements

* Linux (glibc 2.17+) or macOS (Apple Silicon)
* Bash shell
* Perl
* curl
* A directory `$HOME/bin` in your `$PATH`

## Installation

First, create the target directory and download the installation script:

```bash
# Create bin directory if it doesn't exist
mkdir -p ~/bin

# Download the installation script
curl -LO https://raw.githubusercontent.com/wang-q/builds/master/install.sh
chmod +x install.sh

# Download and install jq (required for the installation script)
curl -LO https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64
chmod +x jq-linux-amd64
mv jq-linux-amd64 ~/bin/jq
# or sudo apt install jq

# Verify the installation
bash install.sh -h

```

Make sure `~/bin` is in your `$PATH`. Add the following line to your `~/.bashrc` if needed:

```bash
export PATH="$HOME/bin:$PATH"

```

## Available Commands

This section provides instructions for downloading and installing pre-built binaries. The process:

1. Creates the target directory if it doesn't exist
2. Fetches the list of available binaries from GitHub
3. Downloads and extracts each binary package
4. Manages installed packages and their files

```bash
# List all available packages
bash install.sh -a              # List all packages
bash install.sh --linux         # List Linux packages
bash install.sh --macos         # List macOS packages

# List installed packages
bash install.sh -l              # List all installed packages
bash install.sh -l pigz         # List files in package pigz

# List foreign files
bash install.sh -f              # List files not managed by the package manager

# Install specific package(s)
bash install.sh pigz multiz     # Install one or more packages

# Remove package(s)
bash install.sh -r pigz         # Remove one or more packages
bash install.sh -u pigz         # Alternative way to remove packages

# Show help message
bash install.sh -h              # Show usage information
bash install.sh --help          # Alternative way to show help

# Development Commands
bash install.sh -b              # List packages in script/ but not built

```

## Package List

```text
==> Available packages for linux
  ASTER
  DALIGNER        DAZZ_DB
  FASTGA          FASTK           FastTree
  MERQURY.FK
  TRF
  anchr           argtable
  bcalm           bcftools        bifrost         boost           bwa
  bzip2
  clustalo        consel
  datamash        diamond
  expat
  faops           fastqc          fd              freebayes
  gdbm
  hmmer           hmmer2          hnsm            htslib          hyperfine
  intspan
  lastz           libdeflate      libpng          libxcrypt
  mash            megahit         minimap2        miniprot        mmseqs
  mosdepth        multiz          mummer          muscle
  ncurses         newick-utils    nwr
  paml            pgr             phast           phylip          picard
  pigz            pixman
  raxml-ng        readline        reseek          ripgrep
  samtools        sickle          spoa            sqlite
  tealdeer        tokei           trimal          tsv-utils
  usearch
  xz
  zlib

```

# Developer Guide

## Project Design

This project is designed like a package manager (similar to Homebrew), with the following features:

1. Standardized build process
    * Download source code from official releases
    * Extract and prepare in temporary directory
    * Cross-compile with Zig
    * Package and distribute as tarballs

2. Cross-platform support
    * Linux: glibc 2.17 (CentOS 7) compatibility
    * macOS: aarch64 (Apple Silicon) native
    * Zig as cross-compiler for consistent builds

3. Unified directory structure
    * `src/` - Source packages
    * `script/` - Build scripts and common functions
    * `tar/` - Build artifacts for distribution

4. Modular design
    * `common.sh` - Shared build environment and functions
    * `install.sh` - Package installation manager
    * Individual build script for each package

The main focus is on bioinformatics tools, with special attention to glibc 2.17 (CentOS 7)
compatibility.

## Build requirements

- Linux or Windows WSL
- Zig 0.13.0
- Rust
- Git
- file

### Zig

```bash
# Download and install Zig
mkdir -p $HOME/share
cd $HOME/share

# linux
curl -L https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz > zig.tar.xz
tar xvfJ zig.tar.xz
mv zig-linux-x86_64* zig
ln -s $HOME/share/zig/zig $HOME/bin/zig

# macos
curl -L https://ziglang.org/download/0.13.0/zig-macos-aarch64-0.13.0.tar.xz > zig.tar.xz
tar xvfJ zig.tar.xz
mv zig-macos-aarch64* zig
ln -s $HOME/share/zig/zig $HOME/bin/zig

# Verify Zig target
zig targets | jq .libc

```

### git lfs

```bash
sudo apt install git-lfs

git lfs install
git lfs track "src/*.tar.gz"
git lfs track "tar/*.tar.gz"

```

### Other tools

```bash
# cmake
curl -LO https://github.com/Kitware/CMake/releases/download/v3.31.5/cmake-3.31.5-linux-x86_64.sh
bash cmake-3.31.5-linux-x86_64.sh
mv cmake-3.31.5-linux-x86_64 cmake
ln -s $HOME/share/cmake/bin/cmake $HOME/bin/cmake

# ninja
curl -LO https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-linux.zip
chmod +x ninja
mv ninja $HOME/bin/
rm ninja-linux.zip

# meson
pip3 install meson

```

### Rust

```bash
# Install Rust using rustup
curl https://sh.rustup.rs -sSf | bash -s -- -y

# Install cargo-zigbuild for cross-compiling Rust projects
cargo install --locked cargo-zigbuild

rustup target list

rustup target add x86_64-unknown-linux-gnu
rustup target add aarch64-apple-darwin

```

## Source Management

### Source tarballs

```bash
# Basic libraries
curl -o src/zlib.tar.gz -L https://zlib.net/zlib-1.3.1.tar.gz

curl -o src/bzip2.tar.gz -L https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz

curl -o src/xz.tar.gz -L https://github.com/tukaani-project/xz/releases/download/v5.6.4/xz-5.6.4.tar.gz

curl -o src/gdbm.tar.gz -L https://ftp.gnu.org/gnu/gdbm/gdbm-1.24.tar.gz

curl -o src/expat.tar.gz -L https://github.com/libexpat/libexpat/releases/download/R_2_6_4/expat-2.6.4.tar.gz

# berkeley-db
curl -L https://download.oracle.com/berkeley-db/db-5.3.28.tar.gz |
    tar xvfz - &&
    mv db-5.3.28 berkeley-db &&
    rm -fr berkeley-db/docs/ &&
    rm -fr berkeley-db/examples/ &&
    rm -fr berkeley-db/lang/ &&
    rm -fr berkeley-db/tests/ &&
    tar -czf src/berkeley-db.tar.gz berkeley-db/ &&
    rm -rf berkeley-db

curl -o src/libpng.tar.gz -L https://sourceforge.net/projects/libpng/files/libpng16/1.6.47/libpng-1.6.47.tar.gz/download

curl -o src/pixman.tar.gz -L https://cairographics.org/releases/pixman-0.44.2.tar.gz

curl -L https://downloads.sourceforge.net/project/argtable/argtable/argtable-2.13/argtable2-13.tar.gz |
    tar xvfz - &&
    mv argtable2-13 argtable &&
    tar -czf src/argtable.tar.gz argtable/ &&
    rm -rf argtable

curl -L https://github.com/besser82/libxcrypt/releases/download/v4.4.38/libxcrypt-4.4.38.tar.xz |
    tar xvfJ - &&
    mv libxcrypt-4.4.38 libxcrypt &&
    tar -czf src/libxcrypt.tar.gz libxcrypt/ &&
    rm -rf libxcrypt

curl -o src/ncurses.tar.gz -L https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz

curl -o src/readline.tar.gz -L https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz

curl -o src/sqlite.tar.gz -L https://www.sqlite.org/2025/sqlite-autoconf-3490100.tar.gz

curl -o src/gsl.tar.gz -L https://ftp.gnu.org/gnu/gsl/gsl-2.8.tar.gz

curl -L https://archives.boost.io/release/1.74.0/source/boost_1_74_0.tar.gz |
    tar xvfz - \
        --exclude='libs/math/test/*' \
        --exclude='libs/geometry/test/*' \
        --exclude='libs/gil/test/*' \
        --exclude='libs/multiprecision/test/*' \
        --exclude='libs/beast/test/*' \
        --exclude='libs/*/example/*' \
        --exclude='libs/*/doc/*' \
        --exclude='*.html' \
        --exclude='*.htm' \
        --exclude='*.pdf' \
        --exclude='*.png' \
        --exclude='*.jpg' \
        --exclude='*.gif' \
        --exclude='*.bmp' \
        --exclude='*.css' \
        --exclude='*.js' \
        --exclude='*.txt' \
        --exclude='*.dat' \
        --exclude='*.dat' \
        --exclude='*.qbk' \
        --exclude='*.svg' \
        --exclude='*.xml' &&
    mv boost_1_74_0 boost &&
    tar -czf src/boost.tar.gz boost/ &&
    rm -rf boost

curl -o src/eigen.tar.gz -L https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz

curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/openmp-19.1.7.src.tar.xz |
    tar xvfJ - &&
    mv openmp-19.1.7.src libomp &&
    tar -czf src/libomp.tar.gz libomp/ &&
    rm -rf libomp

curl -o src/clapack.tar.gz -L https://www.netlib.org/clapack/clapack-3.2.1-CMAKE.tgz

# Makefile
curl -o src/pigz.tar.gz -L https://github.com/madler/pigz/archive/refs/tags/v2.8.tar.gz

curl -o src/bwa.tar.gz -L https://github.com/lh3/bwa/archive/refs/tags/v0.7.18.tar.gz

curl -o src/minimap2.tar.gz -L https://github.com/lh3/minimap2/archive/refs/tags/v2.28.tar.gz

curl -o src/miniprot.tar.gz -L https://github.com/lh3/miniprot/archive/refs/tags/v0.13.tar.gz

curl -o src/lastz.tar.gz -L https://github.com/lastz/lastz/archive/refs/tags/1.04.41.tar.gz

curl -o src/sickle.tar.gz -L https://github.com/najoshi/sickle/archive/refs/tags/v1.33.tar.gz

curl -o src/faops.tar.gz -L https://github.com/wang-q/faops/archive/refs/tags/0.8.22.tar.gz

curl -o src/phylip.tar.gz -L https://phylipweb.github.io/phylip/download/phylip-3.697.tar.gz

curl -o src/mafft.tar.gz -L https://gitlab.com/sysimm/mafft/-/archive/v7.526/mafft-v7.526.tar.gz

curl -o src/phast.tar.gz -L https://github.com/CshlSiepelLab/phast/archive/refs/tags/v1.7.tar.gz

# just .tar file
curl -L http://stat.sys.i.kyoto-u.ac.jp/prog/consel/pub/cnsls020.tgz |
    tar xvf - &&
    tar -czf src/consel.tar.gz consel/ &&
    rm -fr consel

# remove unnecessary files to reduce source size
curl -L https://github.com/inab/trimal/archive/refs/tags/v1.5.0.tar.gz |
    tar xvfz - &&
    rm -fr trimal-1.5.0/dataset/ &&
    rm -fr trimal-1.5.0/docs/ &&
    tar -czf src/trimal.tar.gz trimal-1.5.0/ &&
    rm -rf trimal-1.5.0

curl -L https://github.com/arq5x/bedtools2/archive/refs/tags/v2.31.1.tar.gz |
    tar xvfz - \
        --exclude='*/docs*' \
        --exclude='*/data*' \
        --exclude='*/genomes*' \
        --exclude='*/tes*t' \
        --exclude='*/tutorial*' &&
    mv bedtools2-2.31.1 bedtools &&
    tar -czf src/bedtools.tar.gz bedtools/ &&
    rm -rf bedtools

# use specific commit to ensure reproducibility
curl -o src/DAZZ_DB.tar.gz -L https://github.com/thegenemyers/DAZZ_DB/archive/be65e5991ec0aa4ebbfa926ea00e3680de7b5760.tar.gz

curl -o src/DALIGNER.tar.gz -L https://github.com/thegenemyers/DALIGNER/archive/a8e2f42f752f21d21c92fbc39c75b16b52c6cabe.tar.gz

curl -o src/FASTK.tar.gz -L https://github.com/thegenemyers/FASTK/archive/ddea6cf254f378db51d22c6eb21af775fa9e1f77.tar.gz

curl -o src/MERQURY.FK.tar.gz -L https://github.com/thegenemyers/MERQURY.FK/archive/a1005336b0eae8a1dd478017e3dbbae5366ccda5.tar.gz

curl -o src/FASTGA.tar.gz -L https://github.com/thegenemyers/FASTGA/archive/e97c33ef4daeafdfbb7b5dda56d31eaac9a5e214.tar.gz

curl -o src/multiz.tar.gz -L https://github.com/wang-q/multiz/archive/633c0f7814c887e9e7468ad42076d62496651cb8.tar.gz

curl -o src/paml.tar.gz -L https://github.com/abacus-gene/paml/archive/01508dd10b6e7c746a0768ee3cddadb5c28d5ae0.tar.gz

curl -L https://github.com/chaoszhang/ASTER/archive/e8da7edf8adf4205cf5551630dc77bb81497092b.tar.gz |
    tar xvfz - &&
    mv ASTER-* ASTER &&
    rm -fr ASTER/example &&
    rm ASTER/exe/* &&
    tar -czf src/ASTER.tar.gz ASTER/ &&
    rm -rf ASTER

# ./configure
curl -o src/datamash.tar.gz -L https://ftp.gnu.org/gnu/datamash/datamash-1.8.tar.gz

curl -o src/TRF.tar.gz -L https://github.com/Benson-Genomics-Lab/TRF/archive/refs/tags/v4.09.1.tar.gz

curl -o src/hmmer.tar.gz -L http://eddylab.org/software/hmmer/hmmer-3.4.tar.gz

# hmmer2: rename package to avoid conflict with hmmer3
curl -L http://eddylab.org/software/hmmer/2.4i/hmmer-2.4i.tar.gz |
    tar xvfz - &&
    mv hmmer-2.4i hmmer2 &&
    tar -czf src/hmmer2.tar.gz hmmer2/ &&
    rm -rf hmmer2

curl -o src/MaSuRCA.tar.gz -L https://github.com/alekseyzimin/masurca/releases/download/v4.1.2/MaSuRCA-4.1.2.tar.gz

curl -o src/mummer.tar.gz -L https://github.com/mummer4/mummer/releases/download/v4.0.1/mummer-4.0.1.tar.gz

curl -L http://www.clustal.org/omega/clustal-omega-1.2.4.tar.gz |
    tar xvfz - &&
    mv clustal-omega-1.2.4 clustalo &&
    tar -czf src/clustalo.tar.gz clustalo/ &&
    rm -rf clustalo

# The .tar.gz source code from GitHub equires autoconf/automake to generate ./configure
curl -L https://github.com/samtools/htslib/releases/download/1.21/htslib-1.21.tar.bz2 |
    tar xvfj - &&
    tar -czf src/htslib.tar.gz htslib-1.21/ &&
    rm -rf htslib-1.21

curl -L https://github.com/samtools/samtools/releases/download/1.21/samtools-1.21.tar.bz2 |
    tar xvfj - &&
    tar -czf src/samtools.tar.gz samtools-1.21/ &&
    rm -rf samtools-1.21

curl -L https://github.com/samtools/bcftools/releases/download/1.21/bcftools-1.21.tar.bz2 |
    tar xvfj - &&
    tar -czf src/bcftools.tar.gz bcftools-1.21/ &&
    rm -rf bcftools-1.21

# masurca
# snp-sites
# gatk

# cmake
curl -o src/bifrost.tar.gz -L https://github.com/pmelsted/bifrost/archive/refs/tags/v1.3.5.tar.gz

curl -o src/spoa.tar.gz -L https://github.com/rvaser/spoa/archive/refs/tags/4.1.4.tar.gz

curl -o src/diamond.tar.gz -L https://github.com/bbuchfink/diamond/archive/refs/tags/v2.1.11.tar.gz

curl -o src/libdeflate.tar.gz -L https://github.com/ebiggers/libdeflate/archive/refs/tags/v1.23.tar.gz

# Remove large files
curl -L https://github.com/tjunier/newick_utils/archive/da121155a977197cab9fbb15953ca1b40b11eb87.tar.gz |
    tar xvfz - &&
    mv newick_utils-da121155a977197cab9fbb15953ca1b40b11eb87 newick-utils &&
     fd -t f -S +500k . newick-utils -X rm &&
    tar -czf src/newick-utils.tar.gz newick-utils/ &&
    rm -rf newick-utils

# manually
mkdir -p FastTree &&
    curl -o FastTree/FastTree.c -L https://raw.githubusercontent.com/morgannprice/fasttree/refs/heads/main/old/FastTree-2.1.11.c &&
    tar -czf src/FastTree.tar.gz FastTree/ &&
    rm -fr FastTree

# Rust projects
curl -o src/fd.tar.gz -L https://github.com/sharkdp/fd/archive/refs/tags/v10.2.0.tar.gz

curl -o src/ripgrep.tar.gz -L https://github.com/BurntSushi/ripgrep/archive/refs/tags/14.1.1.tar.gz

curl -o src/bat.tar.gz -L https://github.com/sharkdp/bat/archive/refs/tags/v0.25.0.tar.gz

curl -o src/hyperfine.tar.gz -L https://github.com/sharkdp/hyperfine/archive/refs/tags/v1.19.0.tar.gz

curl -o src/tealdeer.tar.gz -L https://github.com/tealdeer-rs/tealdeer/archive/refs/tags/v1.7.1.tar.gz

curl -o src/tokei.tar.gz -L https://github.com/XAMPPRocky/tokei/archive/refs/tags/v12.1.2.tar.gz

curl -o src/nwr.tar.gz -L https://github.com/wang-q/nwr/archive/refs/tags/v0.7.7.tar.gz

curl -o src/intspan.tar.gz -L https://github.com/wang-q/intspan/archive/refs/tags/v0.8.4.tar.gz

curl -o src/hnsm.tar.gz -L https://github.com/wang-q/hnsm/archive/refs/tags/v0.3.1.tar.gz

curl -o src/pgr.tar.gz -L https://github.com/wang-q/pgr/archive/refs/tags/v0.1.0.tar.gz

curl -o src/anchr.tar.gz -L https://github.com/wang-q/anchr/archive/fadc09fe502e7b31cf6bbd9fa29b7188bf42ae3a.tar.gz

```

### Source codes from Git Repositories

This section clones recursively and sets up all required git repo at specific commits for
reproducibility.

```bash
# bcalm
REPO=bcalm
git clone --recursive https://github.com/GATB/${REPO}.git
cd ${REPO}
git checkout v2.2.3

rm -rf .git
rm -rf gatb-core/.git
cd ..
tar -cf - ${REPO}/ | gzip -9 > src/${REPO}.tar.gz
rm -rf ${REPO}

```

## Build Process

This section contains build instructions for each component. Note that:

1. All builds use Zig as the cross-compiler targeting glibc 2.17 for Linux and aarch64 for macOS
2. Build artifacts are packaged into .tar.gz files and stored in the `tar/` directory
3. Each build is performed in a temporary directory to avoid polluting the source directory

### Basic Libraries

```bash
bash script/zlib.sh
bash script/libdeflate.sh
bash script/bzip2.sh
bash script/xz.sh

bash install.sh zlib libdeflate bzip2 xz

bash script/ncurses.sh
bash script/readline.sh

bash install.sh ncurses readline

bash script/sqlite.sh

bash script/gdbm.sh
bash script/expat.sh
bash script/pixman.sh
bash script/libpng.sh

bash script/argtable.sh
bash script/libxcrypt.sh

# --with-libdeflate
bash script/htslib.sh

```

### `Makefile`

```bash
bash script/DAZZ_DB.sh
bash script/DALIGNER.sh

bash script/lastz.sh
bash script/ASTER.sh
bash script/trimal.sh
bash script/phylip.sh
bash script/consel.sh
bash script/paml.sh

# depend on zlib
bash script/MERQURY.FK.sh
bash script/FASTGA.sh

bash script/bwa.sh
bash script/minimap2.sh
bash script/miniprot.sh

bash script/pigz.sh
bash script/multiz.sh
bash script/sickle.sh
bash script/faops.sh

# bash script/mafft.sh # mafft has hard-coded paths

# build without CLAPACK
bash script/phast.sh

# Depend on zlib, libdeflate and libhts
bash script/FASTK.sh

```

### `CLAPACK`

```bash
mkdir -p static-linux/include
mkdir -p static-linux/lib

bash script/clapack.sh linux

```

### `./configure`

```bash
bash script/datamash.sh

bash script/TRF.sh
bash script/hmmer.sh
bash script/hmmer2.sh
bash script/mummer.sh

# bundled htslib
bash script/samtools.sh
bash script/bcftools.sh

# depend on argtable
bash install.sh argtable
bash script/clustalo.sh

```

### `cmake`

```bash
bash script/bifrost.sh
bash script/spoa.sh
bash script/diamond.sh
bash script/bcalm.sh
bash script/newick-utils.sh

```

### Projects requiring specific build environments

```bash
# Built on a CentOS 7 VM with gcc 4.8
bash script/boost.sh

# use system libgomp
bash script/FastTree.sh

```

### Rust projects

```bash
# System tools
bash script/rust.sh fd
bash script/rust.sh ripgrep
# bash script/rust.sh bat
bash script/rust.sh hyperfine
bash script/rust.sh tealdeer
bash script/rust.sh tokei

# Bioinformatics tools
bash script/rust.sh intspan
bash script/rust.sh nwr
bash script/rust.sh hnsm
bash script/rust.sh pgr
bash script/rust.sh anchr

```

## Binary tarballs

```bash
BIN=usearch
curl -o ${BIN} -L https://github.com/rcedgar/usearch12/releases/download/v12.0-beta1/usearch_linux_x86_12.0-beta
chmod +x ${BIN}
tar -cf - ${BIN} | gzip -9 > tar/${BIN}.linux.tar.gz
rm ${BIN}

BIN=reseek
curl -o ${BIN} -L https://github.com/rcedgar/reseek/releases/download/v2.3/reseek-v2.3-linux-x86
chmod +x ${BIN}
tar -cf - ${BIN} | gzip -9 > tar/${BIN}.linux.tar.gz
rm ${BIN}

BIN=muscle
curl -o ${BIN} -L https://github.com/rcedgar/muscle/releases/download/v5.3/muscle-linux-x86.v5.3
chmod +x ${BIN}
tar -cf - ${BIN} | gzip -9 > tar/${BIN}.linux.tar.gz
rm ${BIN}

BIN=mosdepth
curl -o ${BIN} -L https://github.com/brentp/mosdepth/releases/download/v0.3.11/mosdepth
chmod +x ${BIN}
tar -cf - ${BIN} | gzip -9 > tar/${BIN}.linux.tar.gz
rm ${BIN}

# bash script/libomp.sh

bash script/tsv-utils.sh
bash script/pup.sh

bash script/raxml-ng.sh
bash script/mash.sh
bash script/megahit.sh
bash script/mmseqs.sh
bash script/freebayes.sh
bash script/iqtree2.sh

# java
bash script/fastqc.sh
bash script/picard.sh

```

## Dynamic Library Dependencies

The binaries in this project have minimal dynamic library dependencies:

1. Core System Libraries
    * linux-vdso.so.1 - Virtual dynamic shared object
    * libc.so.6 - GNU C Library (glibc)
    * libpthread.so.0 - POSIX threads library
    * libdl.so.2 - Dynamic linking library
    * /lib64/ld-linux-x86-64.so.2 - Dynamic linker/loader

2. C/C++ Runtime Libraries
    * libstdc++.so.6 - GNU Standard C++ Library
    * libm.so.6 - Math library
    * libgcc_s.so.1 - GCC support library

Example of checking dependencies:

```text
$ ldd ~/bin/trimal
        linux-vdso.so.1 (0x00007ffff4599000)
        libstdc++.so.6 => /lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f796772c000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f7967643000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f7967615000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f7967403000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f79679b6000)

$ bash install.sh --dep trimal
==> Dependencies for package trimal:
  File: readal
    No additional dependencies

  File: statal
    No additional dependencies

  File: trimal
    No additional dependencies

$ bash install.sh --dep muscle
==> Dependencies for package muscle:
  File: muscle
    Static executable

$ bash install.sh --dep bwa
==> Dependencies for package bwa:
  File: bwa
        librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007fb1c7f8c000)

```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

# FAQ

## Why use Zig for cross-compilation?

Zig provides a consistent cross-compilation experience across different platforms and targets
specific glibc versions, which is essential for compatibility with older Linux distributions like
CentOS 7.

## How does this compare to Conda/Bioconda?

While Conda provides a comprehensive package management system, this project focuses specifically
on:

- Minimal dependencies (no Python required)
- Static linking where possible
- Specific glibc compatibility
- Apple Silicon native support

## Can I use these binaries in a Docker container?

Yes, these binaries are ideal for Docker containers as they have minimal dependencies and will work
on any Linux system with glibc 2.17 or newer.

## How do I request a new package?

Open an issue on GitHub with the package name, source URL, and any specific build requirements.
