#!/bin/sh

set -eux

LLVM=$HOME/src/llvm-master
ZIG=$HOME/src/zig
LLVM_VERSION=16

cat $LLVM/clang/tools/driver/driver.cpp > $ZIG/src/zig_clang_driver.cpp
cat $LLVM/clang/tools/driver/cc1_main.cpp > $ZIG/src/zig_clang_cc1_main.cpp
cat $LLVM/clang/tools/driver/cc1as_main.cpp > $ZIG/src/zig_clang_cc1as_main.cpp
cat $LLVM/llvm/tools/llvm-ar/llvm-ar.cpp > $ZIG/src/zig_llvm-ar.cpp

cp -R $LLVM/out/lib/clang/$LLVM_VERSION/include/* $ZIG/lib/include/

cp -R $LLVM/libcxx/{src,include} $ZIG/lib/libcxx/
cp -R $LLVM/libcxxabi/{src,include} $ZIG/lib/libcxxabi/
cp -R $LLVM/libunwind/{src,include} $ZIG/lib/libunwind/

find lib/ -type f -name CMakeLists.txt -exec rm {} ';'
find lib/ -type f -name *.in -exec rm {} ';'
find lib/ -type f -name *.imp -exec rm {} ';'

zig run $ZIG/tools/update_cpu_features.zig -- $LLVM/out/bin/llvm-tblgen $LLVM $ZIG

zig run $ZIG/tools/update_clang_options.zig -- $LLVM/out/bin/llvm-tblgen $LLVM > $ZIG/src/clang_options_data.zig
