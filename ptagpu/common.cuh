#ifndef COMMON_HEADER
#define COMMON_HEADER

#define BASE (30U)
#define NEXT (31U)
#define ELEMENT_WIDTH 32
#define ELEMENT_CARDINALITY (30 * 32)
#define BASE_OF(x) ((x) / ELEMENT_CARDINALITY)
#define WORD_OF(x) (div32((x) % ELEMENT_CARDINALITY))
#define BIT_OF(x) (mod32(x))
#define WARP_SIZE 32
// important, limit to 512 threads per threadblock, otherwise we exceed 64K register limit
#define THREADS_PER_BLOCK 512
#define N_BLOCKS 80

#define PTS 0
#define PTS_CURR 1
#define PTS_NEXT 2
#define COPY 3
#define LOAD 4
#define STORE 5
#define N_TYPES 6

// total 10GiB of GPU memory
#define SIZE_TOTAL_BYTES 10 * 1024 * 1024 * 1024UL
#define SIZE_MIB_PTS_CURR 1500L
#define SIZE_MIB_PTS_NEXT 2000L
#define SIZE_MIB_COPY 1000L
#define SIZE_MIB_LOAD 700L
#define SIZE_MIB_STORE 700L

#define TOTAL_MEMORY_LENGTH SIZE_TOTAL_BYTES / sizeof(unsigned int)
#define OFFSET_PTS OFFSET_PTS_CURR + (SIZE_MIB_PTS_CURR * 1024 * 1024 / sizeof(unsigned int))
#define OFFSET_PTS_CURR OFFSET_PTS_NEXT + (SIZE_MIB_PTS_NEXT * 1024 * 1024 / sizeof(unsigned int))
#define OFFSET_PTS_NEXT OFFSET_COPY + (SIZE_MIB_COPY * 1024 * 1024 / sizeof(unsigned int))
#define OFFSET_COPY OFFSET_LOAD + (SIZE_MIB_LOAD * 1024 * 1024 / sizeof(unsigned int))
#define OFFSET_LOAD OFFSET_STORE + (SIZE_MIB_STORE * 1024 * 1024 / sizeof(unsigned int))
#define OFFSET_STORE 0UL

__device__ __host__ static inline uint div32(uint num)
{
  return num >> 5;
}

__device__ __host__ static inline uint mod32(uint num)
{
  return num & 31;
}

__device__ __host__ static inline uint getDstNode(uint base, uint word, uint bit)
{
  return base * ELEMENT_CARDINALITY + word * WARP_SIZE + bit;
}

#include "shared.h"
#include "svfhook.h"
#include <bitset>
#include <map>
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <thrust/sort.h>
#include <thrust/device_vector.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/iterator/discard_iterator.h>

#define checkCuda(val) check((val), #val, __FILE__, __LINE__)
void check(cudaError_t err, const char *const func, const char *const file, const int line)
{
  if (err != cudaSuccess)
  {
    fprintf(stderr, "CUDA Runtime Error at: '%s:%i'\n\t%s %s\n", file, line, cudaGetErrorString(err), func);
    exit(EXIT_FAILURE);
  }
}

#endif