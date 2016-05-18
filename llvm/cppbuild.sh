#!/bin/bash
# This file is meant to be included by the parent cppbuild.sh script
if [[ -z "$PLATFORM" ]]; then
    pushd ..
    bash cppbuild.sh "$@" llvm
    popd
    exit
fi

case $PLATFORM in
    linux-x86)
        export CC="gcc -m32"
        export CXX="g++ -m32"
        ;;
    linux-x86_64)
        export CC="gcc -m64"
        export CXX="g++ -m64"
        ;;
#    linux-armhf)
#        export CC_FLAGS="clang -target arm -march=armv7 -mfloat-abi=hard"
#        export CXX_FLAGS="-target arm -march=armv7 -mfloat-abi=hard"
#        ;;
    macosx-*)
        ;;
    *)
        echo "Error: Platform \"$PLATFORM\" is not supported"
        return 0
        ;;
esac

LLVM_VERSION=3.9.1
SRC_LLVM="llvm-$LLVM_VERSION.src.tar.xz"
SRC_CFE="cfe-$LLVM_VERSION.src.tar.xz"
download http://llvm.org/releases/$LLVM_VERSION/$SRC_LLVM $SRC_LLVM
download http://llvm.org/releases/$LLVM_VERSION/$SRC_CFE $SRC_CFE

mkdir -p $PLATFORM
cd $PLATFORM
INSTALL_PATH=`pwd`
echo "Extracting $SRC_LLVM"
tar xf ../$SRC_LLVM
cd llvm-$LLVM_VERSION.src
mkdir -p build tools
cd tools
echo "Extracting $SRC_CFE"
tar xf ../../../$SRC_CFE
rm -Rf clang
mv cfe-$LLVM_VERSION.src clang
cd ../build

$CMAKE -DCMAKE_INSTALL_PREFIX=../.. -DDLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=host -DLIBXML2_LIBRARIES= ..
make -j $MAKEJ
make install

cd ../..
