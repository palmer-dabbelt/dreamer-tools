#!/bin/bash -e

if [[ "$1" != "--actually-run" ]]
then
    git pull
    git submodule init
    git submodule update
    $0 --actually-run $@
    exit $?
fi

shift

top="$(pwd)"
prefix="$top/install"
sudo=""

if [[ "$1" != "" ]]
then
    prefix="$1"
    sudo="sudo"
fi

$sudo mkdir -p "$prefix"

$sudo tee "$prefix"/enter <<EOF
export PATH="$prefix/bin:\$PATH"
export PKG_CONFIG_PATH="$prefix/lib/pkgconfig:\$PKG_CONFIG_PATH"
EOF
source "$prefix"/enter

##############################################################################
# pconfigure                                                                 #
##############################################################################
cd "$top"/src/pconfigure/

if test -f "$prefix"/bin/pconfigure
then
    pconfigure
else
    rm -f Configfiles/local
    ./bootstrap.sh --prefix "$prefix"
fi

make
$sudo make install

##############################################################################
# tek                                                                        #
##############################################################################
cd "$top"/src/tek/
pconfigure
make
$sudo make install

##############################################################################
# libflo                                                                     #
##############################################################################
cd "$top"/src/libflo/
pconfigure
make
$sudo make install

##############################################################################
# vcddiff                                                                    #
##############################################################################
cd "$top"/src/vcddiff/
pconfigure
make
$sudo make install

##############################################################################
# flo-llvm                                                                   #
##############################################################################
cd "$top"/src/flo-llvm/
pconfigure
make
$sudo make install

##############################################################################
# flo-llvm                                                                   #
##############################################################################
cd "$top"/src/flo-mwe/
pconfigure
make
$sudo make install
