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

/**
 * Basic function to insert edges into graph
 * This function is slow and running on the CPU
 * it is also assumed, that all edges have the same base and fit into the first word.
 * This is only for testing the kernel.
 */
__host__ __device__ void insertEdge(uint src, uint dst, uint *graph)
{
    uint index = 1 << 12;
    while (graph[index] != UINT_MAX && graph[index+30] != 0)
        index += ELEMENT_WIDTH;
    if(graph[index] == UINT_MAX)
    for (size_t i = 0; i < ELEMENT_WIDTH - 1; i++)
    {
        graph[index + i] = 0;
    }

    graph[index] |= 1 << dst;
    graph[src] = index;
}

__global__ void kernel(int n, uint *A, uint *B, uint *C)
{
    // each warp gets a shared block for one access to global memory
    __shared__ uint _sh_[THREADS_PER_BLOCK / WARP_SIZE * 128];
    uint *const _shared_ = &_sh_[threadIdx.y * 128];
    for (uint src = blockIdx.x * blockDim.x + threadIdx.y; src < n; src += blockDim.x * gridDim.x)
    {
        uint index = A[src];
        do
        {
            uint bits = A[index + threadIdx.x];
            uint base = A[index + BASE];
            if (base == UINT_MAX)
                break;
            // create mask for threads w/ dst nodes, except last 2 (BASE & NEXT)
            uint nonEmptyThreads = __ballot_sync(0x3FFFFFFF, bits);
            const uint threadMask = 1 << threadIdx.x;
            const uint myMask = threadMask - 1;
            while (nonEmptyThreads)
            {
                // work through the nonEmptyThreads bits, get thread number of first thread w/ non empty bits
                int leastThread = __ffs(nonEmptyThreads) - 1;
                // remove lsb from nonEmptyThreads (iteration step)
                nonEmptyThreads &= (nonEmptyThreads - 1);
                // share current bits with all threads in warp
                uint current_bits = __shfl_sync(0x3FFFFFFF, bits, leastThread);
                
                // use the base and the word of the current thread's bits to calculate the target dst id
                uint var = base * 30 * 32 + 32 * leastThread + threadIdx.x;
                // check if this thread is looking at a dst node
                // uint bitActive = (var != 1U) && (current_bits & threadMask);
                uint bitActive = (current_bits & threadMask);
                // count threads that are looking at dst nodes
                uint threadsWithDstNode = __ballot_sync(0xFFFFFFFF, bitActive);
                uint numDstNodes = __popc(threadsWithDstNode);
                // calculate pos in shared mem, by counting prev threads that had a dst node
                uint pos = 0 + __popc(threadsWithDstNode & myMask);
                if (bitActive)
                {
                    _shared_[pos] = var;
                }
            }

            index = A[index + NEXT];
        } while (index != UINT_MAX);
    }
}

__host__ int run()
{
    // CUDA kernel to add elements of two arrays

    int N = 1 << 20;
    uint *pts, *prevPtsDiff, *currPtsDiff, *invCopy, *invStore, *invLoad;

    // Allocate Unified Memory -- accessible from CPU or GPU
    checkCuda(cudaMallocManaged(&pts, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&prevPtsDiff, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&currPtsDiff, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invCopy, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invStore, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invLoad, N * sizeof(uint1)));

    // set all values to UINT_MAX
    cudaMemset(pts, UINT_MAX, N);
    cudaMemset(prevPtsDiff, UINT_MAX, N);
    cudaMemset(currPtsDiff, UINT_MAX, N);
    cudaMemset(invCopy, UINT_MAX, N);
    cudaMemset(invStore, UINT_MAX, N);
    cudaMemset(invLoad, UINT_MAX, N);

    insertEdge(1, 0, pts);
    insertEdge(2, 1, invLoad);
    insertEdge(1, 3, invStore);
    insertEdge(3, 4, pts);

    // Launch kernel on 1M elements on the GPU

    dim3 numBlocks(1);
    dim3 threadsPerBlock(warpSize, 1024 / warpSize);
    kernel<<<numBlocks, threadsPerBlock>>>(5, invCopy, pts, pts);

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