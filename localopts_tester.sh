#! /bin/bash
if [ $1 -eq 1 ] 
then
    cd build
    make -j10 opt
    cd ..
fi

clear
build/bin/opt -p localopts test/foo.ll -o test/foo.optimized.bc
llvm-dis-17 test/foo.optimized.bc -o test/foo.optimized.ll