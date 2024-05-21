#! /bin/bash
if [ $1 -eq 1 ] 
then
    cd build
    make -j10 opt
    cd ..
fi

build/bin/opt -p loop-walk test/loop.base.ll -o test/loop.optimized.bc
llvm-dis-17 test/loop.optimized.bc -o test/loop.optimized.ll
