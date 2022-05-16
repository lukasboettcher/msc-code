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

clang-12 -S -c -Xclang -disable-O0-optnone -fno-discard-value-names -emit-llvm swap.c -o swap.ll
opt-12 -S -mem2reg swap.ll -o swap.ll

# runtime: for diff.bc
## graspan graph contruction:
cpu: 
real    3m25.505s
user    9m51.161s
sys     0m9.784s

gpu:
real    2m47.195s
user    2m41.598s
sys     0m5.399s

## llvm graph construction (only pts to, no alias)
real    0m17.801s
user    1m19.553s
sys     0m0.946s

possible rules to add alias information
# alias edges
#A	A1	p
#A1	-p	A2
#A2
#A2	A3	p
#A3	-p	A2

## debugging graspan
clear && make graspan && graspan/graspan ../graspan_debugging/test-rules.txt ../graspan_debugging/test-edges.txt 1

# analyse dataflow linux kernel
## sparse matrix mm
real    1m57.516s
user    1m44.907s
sys     0m11.942s
## graspan-c
real    7m43.412s
user    6m41.107s
sys     1m13.887s

# graph tool
## for synthetic graph construction

docker run --rm -it -u`id -u` -v `pwd`:/wd -w /wd tiagopeixoto/graph-tool