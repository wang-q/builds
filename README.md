# Builds

```shell
# Cross compiling
brew install zig
zig targets | jq .libc

```

```shell
mkdir -p tar

# DAZZ_DB
git submodule add https://github.com/thegenemyers/DAZZ_DB.git DAZZ_DB

cd DAZZ_DB
git checkout be65e59

cd ..
git add DAZZ_DB
git commit -m "Update DAZZ_DB to be65e59"

```

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
