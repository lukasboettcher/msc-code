#include "common.cuh"

/**
 * getHeadIndex
 *
 * get the index of the first element for a given node
 *
 * \param src the node for which to get the head index
 *
 * \return index of the
 *
 */
__host__ __device__ size_t getHeadIndex(uint src, uint *graph)
{
    return 0;
}

__global__ void kernel(int n, uint *A, uint *B, uint *C)
{
}

__host__ int run()
{
    // CUDA kernel to add elements of two arrays

    int N = 1 << 8;
    uint *pts, *prevPtsDiff, *currPtsDiff, *invCopy, *invStore, *invLoad;

    // Allocate Unified Memory -- accessible from CPU or GPU
    checkCuda(cudaMallocManaged(&pts, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&prevPtsDiff, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&currPtsDiff, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invCopy, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invStore, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invLoad, N * sizeof(uint1)));

    getHeadIndex(0, pts);
    // initialize x and y arrays on the host
    for (int i = 0; i < N; i++)
    {
        pts[i] = 1;
    }

    // Launch kernel on 1M elements on the GPU

    dim3 numBlocks(1);
    dim3 threadsPerBlock(warpSize, 1024 / warpSize);
    kernel<<<numBlocks, threadsPerBlock>>>(N, invCopy, pts, pts);

    // Wait for GPU to finish before accessing on host
    checkCuda(cudaDeviceSynchronize());

    // Free memory
    checkCuda(cudaFree(pts));
    checkCuda(cudaFree(prevPtsDiff));
    checkCuda(cudaFree(currPtsDiff));
    checkCuda(cudaFree(invCopy));
    checkCuda(cudaFree(invStore));
    checkCuda(cudaFree(invLoad));

    return 0;
}