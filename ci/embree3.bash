#!/bin/bash
set -xe

VERSION="3.13.3"
wget -nv https://github.com/embree/embree/releases/download/v${VERSION}/embree-${VERSION}.x86_64.linux.tar.gz -O embree.tar.gz

tar -zxvf embree.tar.gz
rm -f embree.tar.gz
mv embree-${VERSION}.x86_64.linux ~/embree
source embree/embree-vars.sh

