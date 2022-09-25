#ifndef COMMON_HEADER
#define COMMON_HEADER

#include "shared.h"
#include <bitset>
#include <map>
#include <future>
#include <thrust/sort.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/iterator/discard_iterator.h>

typedef unsigned long long int index_t;

#define BASE (29U)
#define NEXT_LOWER (30U)
#define NEXT_UPPER (31U)
#define BV_THREADS_MASK 0x1FFFFFFF
#define FULL_MASK 0xFFFFFFFF
#define ELEMENT_WIDTH 32
#define ELEMENT_CARDINALITY (BASE * 32)
#define BASE_OF(x) ((x) / ELEMENT_CARDINALITY)
#define WORD_OF(x) (div32((x) % ELEMENT_CARDINALITY))
#define BIT_OF(x) (mod32(x))
#define WARP_SIZE 32
// important, limit to 512 threads per threadblock, otherwise we exceed 64K register limit
// now 256 threads per threadblock, if we use 64bit addresses
#define THREADS_PER_BLOCK 256
#define N_BLOCKS 80
// set asize 2^26 uints for key value and offset, total: 256MiB x 3
#define KV_SIZE 240000000 // 67108864

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

static void calculateKernelParams(void *kernel)
{
  int blockSize;
  int minGridSize;

  size_t dynamicSMemUsage = 0;

  double potentialOccupancy;

  void *kernel2check = (void *)kernel;

  checkCuda(cudaOccupancyMaxPotentialBlockSize(
      &minGridSize, &blockSize, (void *)kernel2check, dynamicSMemUsage,
      0));

  std::cout << "Suggested block size: " << blockSize << std::endl
            << "Minimum grid size for maximum occupancy: " << minGridSize
            << std::endl;
  potentialOccupancy =
      reportPotentialOccupancy((void *)kernel2check, blockSize, dynamicSMemUsage);

  std::cout << "Potential occupancy: " << potentialOccupancy * 100 << "%"
            << std::endl;
}

/**
 * 
 * helper function to extract the lower 32 bits of a 64 bit integer
 * 
 */
__device__ __host__ static inline uint getLower(index_t value)
{
  return value & 0xFFFFFFFF;
}

/**
 * 
 * helper function to extract the upper 32 bits of a 64 bit integer
 * 
 */
__device__ __host__ static inline uint getUpper(index_t value)
{
  return value >> 32;
}

/**
 * 
 * helper function to create a 64 bit integer from two 32 bit integers, all being unsigned
 * 
 */
__device__ __host__ static inline index_t load_size_t(uint lower, uint upper)
{
  index_t res = upper;
  res <<= 32;
  res |= lower;
  return res;
}

/**
 * 
 * helper function load a 64 bit index from two threads in a cuda warp
 * 
 */
__device__ static inline index_t thread_load_size_t(uint bits)
{
  uint lower = __shfl_sync(FULL_MASK, bits, NEXT_LOWER);
  uint upper = __shfl_sync(FULL_MASK, bits, NEXT_UPPER);
  return load_size_t(lower, upper);
}

/**
 * 
 * helper function store a 64 bit index into two 32 bit memory locations
 * 
 */
__device__ __host__ static inline void store_size_t(uint *__memory__, index_t index, index_t next)
{
  __memory__[index + NEXT_LOWER] = getLower(next);
  __memory__[index + NEXT_UPPER] = getUpper(next);
}

/**
 * 
 * helper function assign each thread in a warp the right value
 * while splitting a 64bit index into two 32 unsigned ints
 * for the last two threads
 * 
 */
__device__ __host__ static inline uint thread_load_val(uint bits, index_t next)
{
  return threadIdx.x < NEXT_LOWER ? bits : threadIdx.x < NEXT_UPPER ? getLower(next)
                                                                    : getUpper(next);
}

#endif