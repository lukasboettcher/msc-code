
# GPU accelerated Andersen Analysis
Implemented inside the SVF Framework as a Whole Program Analysis

## Dependencies

These are required for compiling this tool.

- LLVM >= 11 && < 14
- NVIDIA Cuda Toolkit v11.7
- clang Compiler

### Installation on Ubuntu 22.04
```bash
sudo apt install build-essential cmake llvm-13 clang-13 \
    libboost-system-dev libboost-thread-dev
# install nvidia cuda toolkit from https://developer.nvidia.com/cuda-downloads
```

## Set up this repo
```bash
# check out the code
git clone --recursive git@github.com:lukasboettcher/msc-code.git
cd msc-code

# Generate a Project Buildsystem
cmake -S . -B ./build

# Compile the Code
cmake --build build/ --parallel $(nproc) --target runptagpu

# Run ptagpu
build/ptagpu/runptagpu -stat=0 <bitcode>
```


## Generating Bitcode
### Simple Programs
```bash
clang-13 -Wall -c -S -emit-llvm -fno-discard-value-names -g -o out.bc <in>
```

### Compilation with wllvm for Complex Programs
```bash
# from https://blog.xiexun.org/compile-linux-llvm.html
pip install wllvm

LLVM_COMPILER=clang LLVM_CC_NAME=clang-13 make CC=wllvm defconfig
LLVM_COMPILER=clang LLVM_CC_NAME=clang-13 make CC=wllvm -j$(nproc)

# extract the bitcode from the target binary, i.e. vmlinux
extract-bc vmlinux -l llvm-link-13
```

```bash
export CC=clang-13
export CXX=clang++-13
export RANLIB=llvm-ranlib-13
export CFLAGS='-g -flto -save-temps'
export CXXFLAGS=$CFLAGS
export LDFLAGS='-flto -fuse-ld=gold -Wl,-plugin-opt=save-temps'

clang-13 -S -c -Xclang -disable-O0-optnone -fno-discard-value-names -emit-llvm swap.c -o swap.ll
opt-13 -S -mem2reg swap.ll -o swap.ll
```
