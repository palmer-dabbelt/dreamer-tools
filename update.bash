top="$(pwd)"
prefix="$top/install"

export PATH="$prefix/bin:$PATH"
export PKG_CONFIG_PATH="$prefix/lib/pkgconfig:$PKG_CONFIG_PATH"

cd src/pconfigure/
./bootstrap.sh --prefix $prefix
make
make install

