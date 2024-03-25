export ROOT=$HOME/università/llvm
export PATH=$ROOT/install/bin:$PATH

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$ROOT/install -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_TARGETS_TO_BUILD=host $ROOT/src/llvm/