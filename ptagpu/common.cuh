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
#define THREADS_PER_BLOCK 512

#define PTS 0
#define COPY 1
#define STORE 2
#define LOAD 3
#define GEP 4
#define N_TYPES 5

__device__ __host__ static inline uint div32(uint num) {
  return num >> 5;
}

__device__ __host__ static inline uint mod32(uint num) {
  return num & 31;
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
        fprintf(stderr, "CUDA Runtime Error at: '%s':%i\n\t%s %s\n", file, line, cudaGetErrorString(err), func);
        exit(EXIT_FAILURE);
    }
}

#endif