#!/bin/bash -ex

if [[ "$1" != "--actually-run" ]]
then
    # The pull might fail, but that's OK, it just means we don't have
    # the remote set up correctly.
    git pull || true

    if test -d /var/cache/git
    then
        git submodule update --init --recursive --reference /var/cache/git
    else
        git submodule update --init --recursive
    fi

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

cpus=1
if test -f /proc/cpuinfo
then
    cpus="$(cat /proc/cpuinfo | grep -c ^processor)"
fi
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
COMPILEOPTS += -g
LINKOPTS    += -g
EOF

pconfigure
make all all_install
$sudo make install

##############################################################################
# chisel-torture                                                             #
##############################################################################
cd "$top"/src/chisel-torture/

cat >Configfile.local <<EOF
LANGUAGES += c++
COMPILEOPTS += -O2 -march=native
COMPILEOPTS += -g
LINKOPTS    += -g
EOF

pconfigure
make all all_install
$sudo make install

##############################################################################
# sbt                                                                        #
##############################################################################
if test ! -f "$prefix"/bin/sbt
then
    wget https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.6/sbt-launch.jar?_ga=1.145208372.1898596055.1415302191 \
        -O "$prefix"/bin/sbt-launch.jar

    cat > "$prefix"/bin/sbt <<"EOF"
#!/bin/bash
SBT_OPTS="-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256M"
java $SBT_OPTS -jar `dirname $0`/sbt-launch.jar "$@"
exit $?
EOF
    chmod oug+x "$prefix"/bin/sbt
fi

# Now that we're done with everything, try and run the tests
if [[ "$check" == "true" ]]
then
    cd $top
    rm -rf check
    for project in $(git submodule | sed 's/^+/ /' | cut -d' ' -f3)
    do
        cd "$top"/$project
        make check
        mkdir -p check
        mkdir -p $top/check/$project
        tar -cC check . | tar -xC $top/check/$project
    done
fi
