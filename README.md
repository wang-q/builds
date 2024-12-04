# Build binaries for glibc 2.17 (CentOS 7)

```shell
# Cross compiling
brew install zig jq
zig targets | jq .libc

```

## submodules

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

```

## DAZZ_DB

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

FN_TAR=DAZZ_DB.86_64-linux-gnu.$(date +"%Y%m%d").tar.gz
GZIP=-9 tar cvfz ${FN_TAR} \
    $(make -p | grep "^all: " | sed 's/^all://')

mv ${FN_TAR} ../tar/

git restore .
make clean

cd ..
git add "tar/${FN_TAR}"
git commit -a -m "${FN_TAR}"

```

```shell

curl -fsSL \
    https://api.github.com/repos/wang-q/builds/git/trees/master?recursive=1 |
    jq -r '.tree[] | select( .path | startswith("tar/DAZZ_DB") ) | .path' |
    parallel -j 1 '
        curl -fsSL -O https://raw.githubusercontent.com/wang-q/builds/master/{}
    '

```
