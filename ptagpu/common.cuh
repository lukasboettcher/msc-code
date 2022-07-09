#ifndef COMMON_HEADER
#define COMMON_HEADER

#include <cstdio>
#include <cuda.h>
#include <cuda_runtime_api.h>

#define checkCuda(val) check((val), #val, __FILE__, __LINE__)
void check(cudaError_t err, const char *const func, const char *const file, const int line)
{
    if (err != cudaSuccess)
    {
        fprintf(stderr, "CUDA Runtime Error at: '%s':%i\n\t%s %s\n", __FILE__, __LINE__, cudaGetErrorString(err), func);
        exit(EXIT_FAILURE);
    }
}

int run();

#endif