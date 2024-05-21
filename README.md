# LICM (3° Assignment)
```
clang-17 -O0 -emit-llvm -S -c test/loop.c -o test/loop.ll
```
> Remember to comment the attributes in loop.ll before using build/bin/opt (as it might cause issues)
```
build/bin/opt -p mem2reg test/loop.ll -o test/loop.base.bc
llvm-dis-17 test/loop.base.bc -o test/loop.base.ll
```

Authors
+ Morselli Leonardo
+ Wang Simone