
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

### ptagpu results

python.bc ptagpu 2m2.827s ander 3m11.537s

bash.bc ptagpu 0m16.312s ander 0m38.319s

wireshark.bc(UI) ptagpu 0m2.755s ander 0m2.374s

perl.bc ptagpu 0m36.619s 0m56.539s

-------------
local results

vim
time update: 4513.788 ms
time kernel: 112369.299 ms
time thrust: 178.973 ms
time store : 20118.042 ms
time svf   : 34238.890 ms
SVF gep time: 8147.53ms
SVF ind time: 4829.88ms

real    3m4.680s
user    3m50.043s
sys     0m36.286s

SVF
real    7m25.984s
user    7m20.615s
sys     0m5.258s

-------------
ignis results

postgres
time update: 57920.007 ms
time kernel: 192074.713 ms
time thrust: 309.619 ms
time store : 31159.732 ms
time svf   : 90968.464 ms
SVF gep time: 34480.4ms
SVF ind time: 50979.2ms

real    6m51.915s
user    8m58.071s
sys     1m53.304s

SVF:
real    11m37.881s
user    11m20.623s
sys     0m16.997s


python
time update: 11808.938 ms
time kernel: 40383.684 ms
time thrust: 267.243 ms
time store : 9413.855 ms
time svf   : 74339.161 ms
SVF gep time: 13415.9ms
SVF ind time: 75951.4ms

real    2m37.556s
user    3m27.655s
sys     1m39.901s

SVF:
real    6m22.921s
user    6m15.135s
sys     0m7.606s


linux SVF
real    399m20.094s
user    387m29.903s
sys     11m39.542s
## notes on flamegraph generation

```bash
git clone https://github.com/brendangregg/FlameGraph  # or download it from github
cd FlameGraph
perf record -F 99 -a -g -- sleep 60
perf script | ./stackcollapse-perf.pl > out.perf-folded
./flamegraph.pl out.perf-folded > perf.svg
firefox perf.svg  # or chrome, etc.
```