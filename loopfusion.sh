#! /bin/bash
if [ $1 -eq 1 ] 
then
    cd build
    make -j10 opt
    cd ..
fi

build/bin/opt -p loop-fusion test/loop-fusion/two-loops.base.ll -o test/loop-fusion/two-loops.optimized.bc
llvm-dis-17 test/loop-fusion/two-loops.optimized.bc -o test/loop-fusion/two-loops.optimized.ll
