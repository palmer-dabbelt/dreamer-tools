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

cpus="$(cat /proc/cpuinfo | grep -c ^processor)"
export MAKEFLAGS="-j$cpus"

##############################################################################
# pconfigure                                                                 #
##############################################################################
cd "$top"/src/pconfigure/

rm -f Configfiles/local
./bootstrap.sh --prefix "$prefix"

make all all_install
$sudo make install

##############################################################################
# tek                                                                        #
##############################################################################
cd "$top"/src/tek/

cat >Configfile.local <<EOF
LANGUAGES += c++
COMPILEOPTS += -O2 -march=native
LINKOPTS    += -Wl,-O1
COMPILEOPTS += -g
LINKOPTS    += -g
EOF

pconfigure
make all all_install
$sudo make install

##############################################################################
# libflo                                                                     #
##############################################################################
cd "$top"/src/libflo/

cat >Configfile.local <<EOF
LANGUAGES += c++
COMPILEOPTS += -O2 -march=native
LINKOPTS    += -Wl,-O1
COMPILEOPTS += -g
LINKOPTS    += -g
EOF

pconfigure
make all all_install
$sudo make install

##############################################################################
# vcddiff                                                                    #
##############################################################################
cd "$top"/src/vcddiff/

cat >Configfile.local <<EOF
LANGUAGES += c++
COMPILEOPTS += -O2 -march=native
LINKOPTS    += -Wl,-O1
COMPILEOPTS += -g
LINKOPTS    += -g
EOF

pconfigure
make all all_install
$sudo make install

##############################################################################
# libocn                                                                     #
##############################################################################
cd "$top"/src/libocn/

cat >Configfile.local <<EOF
LANGUAGES += c++
COMPILEOPTS += -O2 -march=native
LINKOPTS    += -Wl,-O1
COMPILEOPTS += -g
LINKOPTS    += -g
EOF

pconfigure
make all all_install
$sudo make install

##############################################################################
# flo-llvm                                                                   #
##############################################################################
cd "$top"/src/flo-llvm/

cat >Configfile.local <<EOF
LANGUAGES += c++
COMPILEOPTS += -O2 -march=native
LINKOPTS    += -Wl,-O1
COMPILEOPTS += -g
LINKOPTS    += -g
EOF

pconfigure
make all all_install
$sudo make install

##############################################################################
# flo-mwe                                                                    #
##############################################################################
cd "$top"/src/flo-mwe/

cat >Configfile.local <<EOF
LANGUAGES += c++
COMPILEOPTS += -O2 -march=native
LINKOPTS    += -Wl,-O1
COMPILEOPTS += -g
LINKOPTS    += -g
EOF

pconfigure
make all all_install
$sudo make install

##############################################################################
# libdrasm                                                                   #
##############################################################################
cd "$top"/src/libdrasm/

cat >Configfile.local <<EOF
LANGUAGES += c++
COMPILEOPTS += -O2 -march=native
LINKOPTS    += -Wl,-O1
COMPILEOPTS += -g
LINKOPTS    += -g
EOF

pconfigure
make all all_install
$sudo make install

##############################################################################
# dreamer-par                                                                #
##############################################################################
cd "$top"/src/dreamer-par/

cat >Configfile.local <<EOF
LANGUAGES += c++
COMPILEOPTS += -O2 -march=native
LINKOPTS    += -Wl,-O1
COMPILEOPTS += -g
LINKOPTS    += -g
EOF

pconfigure
make all all_install
$sudo make install
