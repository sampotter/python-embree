#!/bin/bash
set -xe

# Fetch the archive from GitHub releases.
wget -nv https://github.com/embree/embree/archive/v3.13.2.zip -O /tmp/embree.zip

# check the sha hash
echo "eaa7a8ecd78594fb9eed75b2abbabd30dd68afb49556c250799daaeec016237c  /tmp/embree.zip" | sha256sum --check
cd /tmp
unzip -q embree.zip
cd embree-3.13.2

mkdir build
cd build
cmake -DEMBREE_ISPC_SUPPORT=0 ..

make
make install
