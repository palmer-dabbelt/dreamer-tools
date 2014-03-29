top="$(pwd)"
prefix="$top/install"

export PATH="$prefix/bin:$PATH"
export PKG_CONFIG_PATH="$prefix/lib/pkgconfig:$PKG_CONFIG_PATH"

cd "$top"/src/pconfigure/
./bootstrap.sh --prefix "$prefix"
make
make install

cd "$top"/src/tek/
pconfigure
make
make install
