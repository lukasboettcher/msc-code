
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
export CC=clang-12
export CXX=clang++-12
export RANLIB=llvm-ranlib-12
export CFLAGS='-g -flto -save-temps'
export CXXFLAGS=$CFLAGS
export LDFLAGS='-flto -fuse-ld=gold -Wl,-plugin-opt=save-temps'

clang-12 -S -c -Xclang -disable-O0-optnone -fno-discard-value-names -emit-llvm swap.c -o swap.ll
opt-12 -S -mem2reg swap.ll -o swap.ll
```

## Results notes
### runtime: for diff.bc on graspan
cpu: <br>
real    3m25.505s<br>
user    9m51.161s<br>
sys     0m9.784s<br>

gpu:<br>
real    2m47.195s<br>
user    2m41.598s<br>
sys     0m5.399s<br>

### llvm graph construction (only pts to, no alias)
real    0m17.801s<br>
user    1m19.553s<br>
sys     0m0.946s<br>

### possible rules to add alias information
#A	A1	p<br>
#A1	-p	A2<br>
#A2<br>
#A2	A3	p<br>
#A3	-p	A2<br>

## debugging graspan
clear && make graspan && graspan/graspan ../graspan_debugging/test-rules.txt ../graspan_debugging/test-edges.txt 1

## analyse dataflow linux kernel
### sparse matrix mm
real    1m57.516s<br>
user    1m44.907s<br>
sys     0m11.942s<br>
### graspan-c
real    7m43.412s<br>
user    6m41.107s<br>
sys     1m13.887s<br>

## graph tool
### for synthetic graph construction

docker run --rm -it -u`id -u` -v `pwd`:/wd -w /wd tiagopeixoto/graph-tool