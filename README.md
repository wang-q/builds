# Build binaries for glibc 2.17

<!-- TOC -->
* [Build binaries for glibc 2.17](#build-binaries-for-glibc-217)
  * [Design](#design)
  * [Requirements](#requirements)
    * [Zig](#zig)
    * [Other build tools](#other-build-tools)
    * [Rust](#rust)
  * [Source codes from git commit](#source-codes-from-git-commit)
  * [Source tarballs](#source-tarballs)
  * [Builds](#builds)
    * [`Makefile`](#makefile)
    * [`CLAPACK`](#clapack)
    * [`./configure`](#configure)
    * [`cmake`](#cmake)
    * [Projects requiring specific build environments](#projects-requiring-specific-build-environments)
    * [Rust projects](#rust-projects)
  * [Binary tarballs](#binary-tarballs)
  * [Download and install binaries to `~/bin`](#download-and-install-binaries-to-bin)
<!-- TOC -->

## Design

This project is designed like a package manager (similar to Homebrew), with the following features:

1. Standardized build process
    * Download source code
    * Extract to temporary directory
    * Configure and compile
    * Package and distribute

2. Cross-platform support
    * Linux (glibc 2.17) and macOS (aarch64)
    * Zig as cross-compiler
    * Handle architecture-specific build parameters

3. Unified directory structure
    * `src/` - Source packages
    * `tar/` - Build artifacts
    * `script/` - Build scripts

4. Modular design
    * `common.sh` - Common functions and variables
    * Individual build script for each package
    * Support building specific packages

The main focus is on bioinformatics tools, with special attention to glibc 2.17 (CentOS 7)
compatibility.

## Requirements

- Linux or Windows WSL
- Zig 0.13.0
- Rust (latest stable version)
- jq 1.7.1+
- Git (latest version)

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

# Download and install jq
curl -LO https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64
chmod +x jq-linux-amd64
mv jq-linux-amd64 ~/bin/jq

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

### Other build tools

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

## Source tarballs

```bash
# Basic libraries
curl -o src/zlib.tar.gz -L https://zlib.net/zlib-1.3.1.tar.gz

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

curl -o src/clapack.tar.gz -L https://www.netlib.org/clapack/clapack-3.2.1-CMAKE.tgz

# Makefile
curl -o src/pigz.tar.gz -L https://github.com/madler/pigz/archive/refs/tags/v2.8.tar.gz

curl -o src/bwa.tar.gz -L https://github.com/lh3/bwa/archive/refs/tags/v0.7.18.tar.gz

curl -o src/minimap2.tar.gz -L https://github.com/lh3/minimap2/archive/refs/tags/v2.28.tar.gz

curl -o src/miniprot.tar.gz -L https://github.com/lh3/miniprot/archive/refs/tags/v0.13.tar.gz

curl -o src/lastz.tar.gz -L https://github.com/lastz/lastz/archive/refs/tags/1.04.41.tar.gz

curl -o src/sickle.tar.gz -L https://github.com/najoshi/sickle/archive/refs/tags/v1.33.tar.gz

curl -o src/faops.tar.gz -L https://github.com/wang-q/faops/archive/refs/tags/0.8.22.tar.gz

curl -o src/mafft.tar.gz -L https://gitlab.com/sysimm/mafft/-/archive/v7.526/mafft-v7.526.tar.gz

curl -o src/phast.tar.gz -L https://github.com/CshlSiepelLab/phast/archive/refs/tags/v1.7.tar.gz

curl -o src/bedtools.tar.gz -L https://github.com/arq5x/bedtools2/releases/download/v2.31.1/bedtools-2.31.1.tar.gz

curl -L https://github.com/inab/trimal/archive/refs/tags/v1.5.0.tar.gz |
    tar xvfz - &&
    rm -fr trimal-1.5.0/dataset/ &&
    rm -fr trimal-1.5.0/docs/ &&
    tar -czf src/trimal.tar.gz trimal-1.5.0/ &&
    rm -rf trimal-1.5.0

# ./configure
curl -o src/datamash.tar.gz -L https://ftp.gnu.org/gnu/datamash/datamash-1.8.tar.gz

curl -o src/TRF.tar.gz -L https://github.com/Benson-Genomics-Lab/TRF/archive/refs/tags/v4.09.1.tar.gz

curl -o src/hmmer.tar.gz -L http://eddylab.org/software/hmmer/hmmer-3.4.tar.gz

curl -L http://eddylab.org/software/hmmer/2.4i/hmmer-2.4i.tar.gz |
    tar xvfz - &&
    mv hmmer-2.4i hmmer2 &&
    tar -czf src/hmmer2.tar.gz hmmer2/ &&
    rm -rf hmmer2

curl -o src/mummer.tar.gz -L https://github.com/mummer4/mummer/releases/download/v4.0.1/mummer-4.0.1.tar.gz

curl -o src/clustal-omega.tar.gz -L http://www.clustal.org/omega/clustal-omega-1.2.4.tar.gz

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
# FastTree
# iqtree2
# gatk
# freebayes
# mosdepth

# cmake
curl -o src/bifrost.tar.gz -L https://github.com/pmelsted/bifrost/archive/refs/tags/v1.3.5.tar.gz

curl -o src/spoa.tar.gz -L https://github.com/rvaser/spoa/archive/refs/tags/4.1.4.tar.gz

curl -o src/diamond.tar.gz -L https://github.com/bbuchfink/diamond/archive/refs/tags/v2.1.11.tar.gz

# standalone
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

curl -o src/pgr.tar.gz -L https://github.com/wang-q/pgr/archive/refs/tags/v0.1.0.tar.gz

```

## Source codes from git commit

This section clones and sets up all required git repo at specific commits for reproducibility.

```bash
# DAZZ_DB
REPO=DAZZ_DB
git clone https://github.com/thegenemyers/${REPO}.git
cd ${REPO}
git checkout be65e59

rm -rf .git
cd ..
tar -cf - ${REPO}/ | gzip -9 > src/${REPO}.tar.gz
rm -rf ${REPO}

# DALIGNER
REPO=DALIGNER
git clone https://github.com/thegenemyers/${REPO}.git
cd ${REPO}
git checkout a8e2f42

rm -rf .git
cd ..
tar -cf - ${REPO}/ | gzip -9 > src/${REPO}.tar.gz
rm -rf ${REPO}

# FASTK
REPO=FASTK
git clone https://github.com/thegenemyers/${REPO}.git
cd ${REPO}
git checkout ddea6cf

rm -rf .git
cd ..
tar -cf - ${REPO}/ | gzip -9 > src/${REPO}.tar.gz
rm -rf ${REPO}

# MERQURY.FK
REPO=MERQURY.FK
git clone https://github.com/thegenemyers/${REPO}.git
cd ${REPO}
git checkout a100533

rm -rf .git
cd ..
tar -cf - ${REPO}/ | gzip -9 > src/${REPO}.tar.gz
rm -rf ${REPO}

# FASTGA
REPO=FASTGA
git clone https://github.com/thegenemyers/${REPO}.git
cd ${REPO}
git checkout e97c33e

rm -rf .git
rm -fr EXAMPLE
cd ..
tar -cf - ${REPO}/ | gzip -9 > src/${REPO}.tar.gz
rm -rf ${REPO}

# multiz
REPO=multiz
git clone https://github.com/wang-q/${REPO}.git
cd ${REPO}
git checkout 633c0f7

rm -rf .git
cd ..
tar -cf - ${REPO}/ | gzip -9 > src/${REPO}.tar.gz
rm -rf ${REPO}

# hnsm
REPO=hnsm
git clone https://github.com/wang-q/${REPO}.git
cd ${REPO}
git checkout f237c5d

rm -rf .git
cd ..
tar -cf - ${REPO}/ | gzip -9 > src/${REPO}.tar.gz
rm -rf ${REPO}

# anchr
REPO=anchr
git clone https://github.com/wang-q/${REPO}.git
cd ${REPO}
git checkout fadc09f

rm -rf .git
cd ..
tar -cf - ${REPO}/ | gzip -9 > src/${REPO}.tar.gz
rm -rf ${REPO}

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

## Builds

This section contains build instructions for each component. Note that:

1. All builds use Zig as the cross-compiler targeting glibc 2.17 for Linux and aarch64 for macOS
2. Build artifacts are packaged into .tar.gz files and stored in the `tar/` directory
3. Each build is performed in a temporary directory to avoid polluting the source directory

### libs

```bash
bash script/zlib.sh
bash install.sh zlib

bash script/gdbm.sh
bash script/expat.sh
bash script/pixman.sh

bash script/argtable.sh

```

### `Makefile`

```bash
bash script/DAZZ_DB.sh
bash script/DALIGNER.sh

bash script/lastz.sh

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

bash script/htslib.sh

# bundled htslib
bash script/samtools.sh
bash script/bcftools.sh

# depend on argtable
bash install.sh argtable
bash script/clustal-omega.sh

```

### `cmake`

```bash
bash script/bifrost.sh
bash script/spoa.sh
bash script/diamond.sh

```

### standalone

```bash
# bash script/FastTree.sh

```

### Projects requiring specific build environments

Built on a CentOS 7 VM

```bash
# zig
bash script/FASTK.sh

# gcc 4.8
bash script/bcalm.sh
bash script/trimal.sh

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

bash script/tsv-utils.sh
bash script/raxml-ng.sh
bash script/mash.sh
bash script/megahit.sh
bash script/mmseqs.sh

# java
bash script/fastqc.sh
bash script/picard.sh

```

## Download and install binaries to `~/bin`

This section provides instructions for downloading and installing all built binaries to your `~/bin`
directory. The process:

1. Creates the target directory if it doesn't exist
2. Fetches the list of available binaries from GitHub
3. Downloads and extracts each binary package

```bash
# List all available packages
bash install.sh -l

# Install specific package(s)
bash install.sh intspan multiz

```

```text
==> Available packages for Linux:
    DALIGNER    DAZZ_DB
    FASTGA      FASTK
    MERQURY.FK
    TRF
    anchr       argtable
    bcalm       bcftools    bifrost     bwa
    clustal-omega
    datamash    diamond
    faops       fastqc      fd
    gdbm
    hmmer       hmmer2      hnsm        htslib      hyperfine
    intspan
    lastz
    mash        megahit     minimap2    miniprot    mmseqs      multiz      mummer      muscle
    nwr
    pgr         phast       picard      pigz        pixman
    raxml-ng    reseek      ripgrep
    samtools    sickle      spoa
    tealdeer    tokei       trimal      tsv-utils
    usearch
    zlib

```
