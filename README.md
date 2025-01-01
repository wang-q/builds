# Build binaries for glibc 2.17 (CentOS 7)

<!-- TOC -->
* [Build binaries for glibc 2.17 (CentOS 7)](#build-binaries-for-glibc-217-centos-7)
  * [Zig](#zig)
  * [Rust](#rust)
  * [Submodules](#submodules)
  * [Builds](#builds)
    * [DAZZ_DB](#dazz_db)
    * [DALIGNER](#daligner)
    * [FASTK](#fastk)
    * [MERQURY.FK](#merquryfk)
    * [FASTGA](#fastga)
    * [intspan](#intspan)
    * [hnsm](#hnsm)
    * [fd](#fd)
    * [anchr](#anchr)
  * [Download and install binaries to `~/bin`](#download-and-install-binaries-to-bin)
<!-- TOC -->

## Zig

```shell
# Cross compiling
brew install zig jq
zig targets | jq .libc

```

```shell
curl -L https://ziglang.org/builds/zig-linux-x86_64-0.14.0-dev.2371+c013f45ad.tar.xz > zig.tar.xz
tar xvfJ zig.tar.xz
mv zig-linux-x86_64* zig
ln -s $HOME/share/zig/zig $HOME/bin/zig

curl -LO https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64
chmod +x jq-linux-amd64
mv jq-linux-amd64 ~/bin/jq

```

## Rust

```shell
curl https://sh.rustup.rs -sSf | bash -s -- -y

cargo install --locked cargo-zigbuild

```

## Submodules

```shell
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
git checkout 7972cbf
cd ..
git add hnsm
git commit -m "Update hnsm to 7972cbf"

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

### DAZZ_DB

```shell
cd DAZZ_DB

git restore .
make clean

sed -i 's/^\t\s*gcc/\t$(CC)/g' Makefile
sed -i '1i CC = zig cc -target x86_64-linux-gnu.2.17' Makefile
# sed -i '1i CC = zig cc' Makefile

sed -i '/^quiva2DB:/{N;N;d;}' Makefile
sed -i '/^DB2quiva:/{N;N;d;}' Makefile
sed -i '/^arrow2DB:/{N;N;d;}' Makefile
sed -i '/^DB2arrow:/{N;N;d;}' Makefile

sed -i \
    -e 's/quiva2DB//g' \
    -e 's/DB2quiva//g' \
    -e 's/arrow2DB//g' \
    -e 's/DB2arrow//g' \
    Makefile

make

FN_TAR=DAZZ_DB.x86_64-linux-gnu.tar.gz
GZIP=-9 tar cvfz ${FN_TAR} \
    $(make -p | grep "^all: " | sed 's/^all://')

mv ${FN_TAR} ../tar/

git restore .
make clean

cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"

```

### DALIGNER

```shell
cd DALIGNER

git restore .
make clean

sed -i 's/^\t\s*gcc/\t$(CC)/g' Makefile
sed -i '1i CC = zig cc -target x86_64-linux-gnu.2.17' Makefile

make

FN_TAR=DALIGNER.x86_64-linux-gnu.tar.gz
GZIP=-9 tar cvfz ${FN_TAR} \
    $(make -p | grep "^all: " | sed 's/^all://')

mv ${FN_TAR} ../tar/

git restore .
make clean

cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"

```

### FASTK

```shell
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

### MERQURY.FK

```shell
cd MERQURY.FK

git restore .
make clean

sed -i 's/^\t\s*gcc/\t$(CC)/g' Makefile
sed -i '1i CC = zig cc' Makefile

make

FN_TAR=MERQURY.FK.centos.tar.gz
GZIP=-9 tar cvfz ${FN_TAR} \
    $(make -p | grep "^all: " | sed 's/^all://')

mv ${FN_TAR} ../tar/

git restore .
make clean

cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"

```

### FASTGA

```shell
cd FASTGA

git restore .
make clean

make CC="zig cc"

FN_TAR=FASTGA.centos.tar.gz
GZIP=-9 tar cvfz ${FN_TAR} \
    $(cat Makefile | grep "^ALL = " | sed 's/^ALL =//')

mv ${FN_TAR} ../tar/

git restore .
make clean

cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"

```

### intspan

```shell
mkdir -p /tmp/cargo
export CARGO_TARGET_DIR=/tmp/cargo

cd intspan

cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 --release
ll $CARGO_TARGET_DIR/x86_64-unknown-linux-gnu/release/

BINS=$(
    cargo read-manifest |
        jq --raw-output '.targets[] | select( .kind[0] == "bin" ) | .name '
)

for BIN in $BINS; do
    cp $CARGO_TARGET_DIR/x86_64-unknown-linux-gnu/release/$BIN .
done

FN_TAR=intspan.x86_64-unknown-linux-gnu.tar.gz
GZIP=-9 tar cvfz ${FN_TAR} \
    $BINS

mv ${FN_TAR} ../tar/
rm $BINS

cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"

```

### hnsm

```shell
mkdir -p /tmp/cargo
export CARGO_TARGET_DIR=/tmp/cargo

cd hnsm

cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 --release
ll $CARGO_TARGET_DIR/x86_64-unknown-linux-gnu/release/

BINS=$(
    cargo read-manifest |
        jq --raw-output '.targets[] | select( .kind[0] == "bin" ) | .name '
)

for BIN in $BINS; do
    cp $CARGO_TARGET_DIR/x86_64-unknown-linux-gnu/release/$BIN .
done

FN_TAR=hnsm.x86_64-unknown-linux-gnu.tar.gz
GZIP=-9 tar cvfz ${FN_TAR} \
    $BINS

mv ${FN_TAR} ../tar/
rm $BINS

cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"

```

### fd

```shell
mkdir -p /tmp/cargo
export CARGO_TARGET_DIR=/tmp/cargo

cd fd

cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 --release
ll $CARGO_TARGET_DIR/x86_64-unknown-linux-gnu/release/

BINS=$(
    cargo read-manifest |
        jq --raw-output '.targets[] | select( .kind[0] == "bin" ) | .name '
)

for BIN in $BINS; do
    cp $CARGO_TARGET_DIR/x86_64-unknown-linux-gnu/release/$BIN .
done

FN_TAR=fd.x86_64-unknown-linux-gnu.tar.gz
GZIP=-9 tar cvfz ${FN_TAR} \
    $BINS

mv ${FN_TAR} ../tar/
rm $BINS

cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"

```

### anchr

```shell
mkdir -p /tmp/cargo
export CARGO_TARGET_DIR=/tmp/cargo

cd anchr

cargo zigbuild --target x86_64-unknown-linux-gnu.2.17 --release
ll $CARGO_TARGET_DIR/x86_64-unknown-linux-gnu/release/

BINS=$(
    cargo read-manifest |
        jq --raw-output '.targets[] | select( .kind[0] == "bin" ) | .name '
)

for BIN in $BINS; do
    cp $CARGO_TARGET_DIR/x86_64-unknown-linux-gnu/release/$BIN .
done

FN_TAR=anchr.x86_64-unknown-linux-gnu.tar.gz
GZIP=-9 tar cvfz ${FN_TAR} \
    $BINS

mv ${FN_TAR} ../tar/
rm $BINS

cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"

```

## Download and install binaries to `~/bin`

```shell
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
