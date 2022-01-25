#!/bin/sh

ROOT_DIR=`pwd`
IMAGE_NAME="webos-ports-emulator-disk.vmdk"

if [ -d build ] ; then
	rm -rf build
fi

mkdir build

wget http://build.webos-ports.org/webos-ports/images/qemux86/webos-ports-dev-image-qemux86.vmdk -O build/$IMAGE_NAME

# NOTE: it's very important that the ovf files is the first file in the tar archive as
# otherwise VirtualBox will fail to load the ova
(cd build ; tar cf ../webos-ports-emulator-`date +"%Y%m%d%H%M%S"`.ova webos-ports-emulator.ovf $IMAGE_NAME)

rm -rf build
