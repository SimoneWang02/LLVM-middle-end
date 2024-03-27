clang-17 -O0 -emit-llvm -c test/foo.c -o test/foo.tester.bc
llvm-dis-17 test/foo.tester.bc -o=./test/foo.tester.ll
