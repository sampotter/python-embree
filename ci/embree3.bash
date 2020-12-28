#!/bin/bash
set -xe

# Fetch the archive from GitHub releases.
wget https://github.com/embree/embree/archive/v3.12.1.zip -O /tmp/embree.zip

# check the sha hash
echo "ef4c6e4e1386e2e93fc46fc4546bf7a5f7c7f9dcd4a64b0041acdd11f4d1e830  /tmp/embree.tar.gz" | sha256sum --check
cd /tmp
unzip embree.zip
cd embree-3.12.1

mkdir build
cd build
ccmake ..

make
make install
