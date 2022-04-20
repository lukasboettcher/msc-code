apt install llvm-12-dev # includes libz3

# https://blog.xiexun.tech/compile-linux-llvm.html
# pip install wllvm

LLVM_COMPILER=clang LLVM_CC_NAME=clang-12 make CC=wllvm defconfig
LLVM_COMPILER=clang LLVM_CC_NAME=clang-12 make CC=wllvm -j$(nproc)
extract-bc vmlinux -l llvm-link-12

export CC=clang-12
export CXX=clang++-12
export RANLIB=llvm-ranlib-12
export CFLAGS='-g -flto -save-temps'
export CXXFLAGS=$CFLAGS
export LDFLAGS='-flto -fuse-ld=gold -Wl,-plugin-opt=save-temps'