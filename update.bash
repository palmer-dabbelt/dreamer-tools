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
master="false"
check="false"

while [[ "$1" != "" ]]
do
    if [[ "$1" == "--prefix" ]]
    then
        prefix="$2"
        sudo="sudo"
        shift
        shift
    elif [[ "$1" == "--master" ]]
    then
        master="true"
        shift
    elif [[ "$1" == "--check" ]]
    then
        check="true"
        shift
    else
        echo "Unable to parse argument: $1" >2
        echo "Did you know the syntax has changed?" >2
        echo "Try --prefix" >2
    fi
done

$sudo mkdir -p "$prefix"

$sudo tee "$prefix"/enter <<EOF
export PATH="$prefix/bin:\$PATH"
export PKG_CONFIG_PATH="$prefix/lib/pkgconfig:\$PKG_CONFIG_PATH"
EOF
source "$prefix"/enter

cpus="$(cat /proc/cpuinfo | grep -c ^processor)"
export MAKEFLAGS="-j$cpus"

# If we've been requested to update everything to master then do so
if [[ "$master" == "true" ]]
then
    for project in $(git submodule | cut -d' ' -f3)
    do
        cd "$top"/$project
        git checkout master
        git pull
    done
fi

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
# chisel-benchmarks                                                          #
##############################################################################
cd "$top"/src/chisel-benchmarks/

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

##############################################################################
# vcd2step                                                                   #
##############################################################################
cd "$top"/src/vcd2step/

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

# Now that we're done with everything, try and run the tests
if [[ "$check" == "true" ]]
then
    cd $top
    rm -rf check
    for project in $(git submodule | cut -d' ' -f3)
    do
        cd "$top"/$project
        make check
        mkdir -p $top/check/$project
        tar -cC check . | tar -xC $top/check/$project
    done
fi
