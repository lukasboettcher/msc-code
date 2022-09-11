#ifndef SHARED_HEADER
#define SHARED_HEADER

#define PTS 0
#define PTS_CURR 1
#define PTS_NEXT 2
#define COPY 3
#define LOAD 4
#define STORE 5
#define N_TYPES 6

// total 10GiB of GPU memory
#define SIZE_TOTAL_BYTES 10 * 1024 * 1024 * 1024UL
#define SIZE_MIB_PTS_CURR 700L
#define SIZE_MIB_PTS_NEXT 1500L
#define SIZE_MIB_COPY 1200L
#define SIZE_MIB_LOAD 200L
#define SIZE_MIB_STORE 200L

#define TOTAL_MEMORY_LENGTH SIZE_TOTAL_BYTES / sizeof(unsigned int)
#define OFFSET_PTS OFFSET_PTS_CURR + (SIZE_MIB_PTS_CURR * 1024 * 1024 / sizeof(unsigned int))
#define OFFSET_PTS_CURR OFFSET_PTS_NEXT + (SIZE_MIB_PTS_NEXT * 1024 * 1024 / sizeof(unsigned int))
#define OFFSET_PTS_NEXT OFFSET_COPY + (SIZE_MIB_COPY * 1024 * 1024 / sizeof(unsigned int))
#define OFFSET_COPY OFFSET_LOAD + (SIZE_MIB_LOAD * 1024 * 1024 / sizeof(unsigned int))
#define OFFSET_LOAD OFFSET_STORE + (SIZE_MIB_STORE * 1024 * 1024 / sizeof(unsigned int))
#define OFFSET_STORE 0UL

#include <vector>
#include <functional>
#include <chrono>

typedef std::pair<std::vector<unsigned int>, std::vector<unsigned int>> edgeSet;

unsigned int *run(unsigned int numNodes, edgeSet *addr, edgeSet *direct, edgeSet *load, edgeSet *store, void *consG, void *pag, std::function<unsigned int(unsigned int *, edgeSet *pts, edgeSet *copy)> callgraphCallback);
bool aliasBV(unsigned int a, unsigned int b, unsigned int *memory);
void collectFromBitvector(uint src, uint *memory, std::vector<uint> &pts, uint rel);

#endif