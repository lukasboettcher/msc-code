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

static double reportPotentialOccupancy(void *kernel, int blockSize,
                                       size_t dynamicSMem)
{
  int device;
  cudaDeviceProp prop;

  int numBlocks;
  int activeWarps;
  int maxWarps;

  double occupancy;

  checkCuda(cudaGetDevice(&device));
  checkCuda(cudaGetDeviceProperties(&prop, device));

  checkCuda(cudaOccupancyMaxActiveBlocksPerMultiprocessor(
      &numBlocks, kernel, blockSize, dynamicSMem));

  activeWarps = numBlocks * blockSize / prop.warpSize;
  maxWarps = prop.maxThreadsPerMultiProcessor / prop.warpSize;

  occupancy = (double)activeWarps / maxWarps;

  return occupancy;
}

#endif