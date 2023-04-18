#!/bin/bash
set -xe

VERSION="4.0.1"

rm -rf /tmp/embree.tar.gz
rm -rf ~/embree

wget -nv https://github.com/embree/embree/releases/download/v${VERSION}/embree-${VERSION}.x86_64.linux.tar.gz -O /tmp/embree.tar.gz
cd /tmp
tar -zxvf embree.tar.gz
rm -f embree.tar.gz

mv embree-${VERSION}.x86_64.linux ~/embree4


