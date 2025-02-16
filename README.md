# Build binaries for glibc 2.17 (CentOS 7)

<!-- TOC -->
* [Build binaries for glibc 2.17 (CentOS 7)](#build-binaries-for-glibc-217-centos-7)
  * [Requirements](#requirements)
  * [Zig](#zig)
  * [Rust](#rust)
  * [Submodules](#submodules)
  * [Builds](#builds)
    * [No deps](#no-deps)
    * [Depend on zlib](#depend-on-zlib)
    * [FASTK](#fastk)
    * [Rust projects](#rust-projects)
  * [Download and install binaries to `~/bin`](#download-and-install-binaries-to-bin)
<!-- TOC -->


This project provides cross-compiled binaries for various bioinformatics tools targeting CentOS 7
(glibc 2.17) environment. It uses Zig as the cross-compiler and Rust for some components.

## Requirements

- Linux or Windows WSL
- Zig 0.14.0-dev.2371+c013f45ad
- Rust (latest stable version)
- jq 1.7.1+
- Git (latest version)

## Zig

```bash
# Install required tools
brew install zig jq

# Verify Zig target
zig targets | jq .libc

```

```bash
# Download and install Zig
curl -L https://ziglang.org/builds/zig-linux-x86_64-0.14.0-dev.2371+c013f45ad.tar.xz > zig.tar.xz
tar xvfJ zig.tar.xz
mv zig-linux-x86_64* zig
ln -s $HOME/share/zig/zig $HOME/bin/zig

# Download and install jq
curl -LO https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64
chmod +x jq-linux-amd64
mv jq-linux-amd64 ~/bin/jq

```

## Rust

```bash
# Install Rust using rustup
curl https://sh.rustup.rs -sSf | bash -s -- -y

# Install cargo-zigbuild for cross-compiling Rust projects
cargo install --locked cargo-zigbuild

rustup target list

rustup target add x86_64-unknown-linux-gnu
rustup target add aarch64-apple-darwin

```

## Submodules

This section clones and sets up all required git submodules at specific commits for reproducibility.

```bash
# Create directory for storing build artifacts
mkdir -p tar

# DAZZ_DB
git submodule add https://github.com/thegenemyers/DAZZ_DB.git DAZZ_DB

cd DAZZ_DB
git checkout be65e59
cd ..
git add DAZZ_DB
git commit -m "Update DAZZ_DB to be65e59"

# DALIGNER
git submodule add https://github.com/thegenemyers/DALIGNER.git DALIGNER

cd DALIGNER
git checkout a8e2f42
cd ..
git add DALIGNER
git commit -m "Update DALIGNER to a8e2f42"

# FASTK
git submodule add https://github.com/thegenemyers/FASTK.git FASTK

cd FASTK
git checkout ddea6cf
cd ..
git add FASTK
git commit -m "Update FASTK to ddea6cf"

# MERQURY.FK
git submodule add https://github.com/thegenemyers/MERQURY.FK.git MERQURY.FK

cd MERQURY.FK
git checkout a100533
cd ..
git add MERQURY.FK
git commit -m "Update MERQURY.FK to a100533"

# FASTGA
git submodule add https://github.com/thegenemyers/FASTGA.git FASTGA

cd FASTGA
git checkout e97c33e
cd ..
git add FASTGA
git commit -m "Update FASTGA to e97c33e"

# multiz
git submodule add https://github.com/wang-q/multiz.git multiz

cd multiz
git checkout 633c0f7
cd ..
git add multiz
git commit -m "Update multiz to 633c0f7"

# intspan
git submodule add https://github.com/wang-q/intspan.git intspan

cd intspan
git checkout v0.8.0
cd ..
git add intspan
git commit -m "Update intspan to v0.8.0"

# hnsm
git submodule add https://github.com/wang-q/hnsm.git hnsm

cd hnsm
git checkout 5b5ec06
cd ..
git add hnsm
git commit -m "Update hnsm to 5b5ec06"

git submodule update --init hnsm
cd hnsm
git pull
git checkout f237c5d
cd ..
git add hnsm
git commit -m "Update hnsm to f237c5d"

# pgr
git submodule add https://github.com/wang-q/pgr.git pgr

cd pgr
git checkout v0.1.0
cd ..
git add pgr
git commit -m "Update intspan to v0.1.0"

# fd
git submodule add https://github.com/sharkdp/fd.git fd

cd fd
git checkout v10.2.0
cd ..
git add fd
git commit -m "Update fd to v10.2.0"

# anchr
git submodule add https://github.com/wang-q/anchr.git anchr

cd anchr
git checkout fadc09f
cd ..
git add anchr
git commit -m "Update anchr to fadc09f"

```

## Builds

This section contains build instructions for each component. Note that:

1. All builds use Zig as the cross-compiler targeting glibc 2.17
2. Build artifacts are packaged into .tar.gz files and stored in the `tar/` directory
3. Each build is followed by cleanup to restore the source directory to its original state

### No deps

```bash
bash script/DAZZ_DB.sh
bash script/DALIGNER.sh

```

### Depend on zlib

```bash
mkdir -p static

curl -L https://zlib.net/zlib-1.3.1.tar.gz |
    tar xvz

cd zlib-1.3.1

CC="zig cc -target x86_64-linux-gnu.2.17" ./configure --static --prefix=../static
make
make install

cd ..
rm -fr zlib-1.3.1

```

```bash
bash script/MERQURY.FK.sh
bash script/FASTGA.sh
bash script/multiz.sh

```

### FASTK

Built under a CentOS 7 VM.

```bash
cd FASTK

git restore .
make clean

make CC="zig cc -D_GNU_SOURCE"

FN_TAR=FASTK.centos.tar.gz
GZIP=-9 tar cvfz ${FN_TAR} \
    $(cat Makefile | grep "^ALL = " | sed 's/^ALL =//')

mv ${FN_TAR} ../tar/

git restore .
make clean
rm LIBDEFLATE/a.out
rm LIBDEFLATE/null.o

cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"

```

### Rust projects

```bash
bash script/rust.sh fd

bash script/rust.sh intspan
bash script/rust.sh hnsm
bash script/rust.sh pgr
bash script/rust.sh anchr

```

## Download and install binaries to `~/bin`

This section provides instructions for downloading and installing all built binaries to your `~/bin`
directory. The process:

1. Creates the target directory if it doesn't exist
2. Fetches the list of available binaries from GitHub
3. Downloads and extracts each binary package in parallel

```bash
# Create target directory if it doesn't exist
mkdir -p $HOME/bin

curl -fsSL \
    https://api.github.com/repos/wang-q/builds/git/trees/master?recursive=1 |
    jq -r '.tree[] | select( .path | startswith("tar/") ) | .path' |
    parallel -j 1 "
        echo >&2 '==> {}'
        curl -fsSL https://raw.githubusercontent.com/wang-q/builds/master/{} |
        tar xvz --directory=$HOME/bin/
    "

```
