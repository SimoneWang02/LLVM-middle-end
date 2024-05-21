### 1° Assignment - Optimization

[Repository](https://github.com/SimoneWang02/first-assignment-llvm)

### 2° Assignment - DFA

[Link](https://docs.google.com/document/d/1Tt-8a6um9oJ8uDEFyBt5Qrmv6G_oo-h8WGUMt3skyhY/edit?usp=sharing) 

### 3° Assignment - LICM

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