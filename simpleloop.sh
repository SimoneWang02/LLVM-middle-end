#! /bin/bash
if [ $1 -eq 1 ] 
then
    cd build
    make -j10 opt
    cd ..
fi

build/bin/opt -p loop-fusion test/loop-fusion/simple-loops/loop.base.ll -o test/loop-fusion/simple-loops/loop.optimized.bc
llvm-dis-17 test/loop-fusion/simple-loops/loop.optimized.bc -o test/loop-fusion/simple-loops/loop.optimized.ll
