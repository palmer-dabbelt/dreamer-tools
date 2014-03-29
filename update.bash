#!/bin/bash -e

git pull
git submodule init
git submodule update

top="$(pwd)"
prefix="$top/install"
sudo=""

if [[ "$1" != "" ]]
then
    prefix="$1"
    sudo="sudo"
fi

$sudo mkdir -p "$prefix"

cat >"$prefix"/enter <<EOF
export PATH="$prefix/bin:\$PATH"
export PKG_CONFIG_PATH="$prefix/lib/pkgconfig:\$PKG_CONFIG_PATH"
EOF
source "$prefix"/enter

echo "Building pconfigure"
cd "$top"/src/pconfigure/

if test -f Configfiles/local
then
    pconfigure
else
    ./bootstrap.sh --prefix "$prefix"
fi

make
$sudo make install

echo "Building tek"
cd "$top"/src/tek/
pconfigure
make
$sudo make install
