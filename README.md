## How to make a new pass?

1. In root/src/llvm/include/llvm/Transforms/Utils, create **NewPass.h**
2. In root/src/llvm/lib/Transforms/Utils, create **NewPass.cpp**
3. In root/src/llvm/lib/Transforms/Utils/**CMakeLists.txt**, add **NewPass.cpp**
4. In root/src/llvm/lib/Passes/**PassRegistry.def**, add **NewPass** function
5. In root/src/llvm/lib/Passes/**PassBuilder.cpp**, include **NewPass.h**

## 1° Assignment - Optimization

[Repository](https://github.com/SimoneWang02/first-assignment-llvm)

## 2° Assignment - DFA

[Link](https://docs.google.com/document/d/1Tt-8a6um9oJ8uDEFyBt5Qrmv6G_oo-h8WGUMt3skyhY/edit?usp=sharing)

## 3° Assignment - LICM

```
clang-17 -O0 -emit-llvm -S -c test/loop.c -o test/loop.ll
```

> Remember to comment the attributes in loop.ll before using build/bin/opt (as it might cause issues)

```
build/bin/opt -p mem2reg test/loop.ll -o test/loop.base.bc
llvm-dis-17 test/loop.base.bc -o test/loop.base.ll
```

## 4° Assignment - Loop Fusion

```
clang-17 -O0 -emit-llvm -S -c test/loop-fusion/two-loops.c -o test/loop-fusion/two-loops.ll
```

> Remember to comment the attributes in two-loops.ll before using build/bin/opt (as it might cause issues)

```
build/bin/opt -p mem2reg test/loop-fusion/two-loops.ll -o test/loop-fusion/two-loops.base.bc
llvm-dis-17 test/loop-fusion/two-loops.base.bc -o test/loop-fusion/two-loops.base.ll
```

## Simple Loop

```
clang-17 -O0 -emit-llvm -S -c test/loop-fusion/simple-loops/loop.c -o test/loop-fusion/simple-loops/loop.ll
```

> Remember to comment the attributes in two-loops.ll before using build/bin/opt (as it might cause issues)

```
build/bin/opt -p mem2reg test/loop-fusion/simple-loops/loop.ll -o test/loop-fusion/simple-loops/loop.base.bc
llvm-dis-17 test/loop-fusion/simple-loops/loop.base.bc -o test/loop-fusion/simple-loops/loop.base.ll
```

Authors

-   Morselli Leonardo
-   Wang Simone
