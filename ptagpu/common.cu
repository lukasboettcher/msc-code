#include "common.cuh"
#include <iostream>
#include <bitset>

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
    uint index = src * 32;
    if (graph[index + BASE] == UINT_MAX)
        for (size_t i = 0; i < ELEMENT_WIDTH - 1; i++)
            graph[index + i] = 0;

    graph[index] |= 1 << dst;
}

__host__ __device__ uint incEdgeCouter()
{
    __shared__ volatile uint _shared_[THREADS_PER_BLOCK / WARP_SIZE];
    if (threadIdx.x == 0)
    {
        _shared_[threadIdx.y] = atomicAdd(&__ptsFreeList__, 32);
    }
    return _shared_[threadIdx.y];
}

__device__ uint __ptsFreeList__;

__global__ void kernel(int n, uint *A, uint *B, uint *C)
{
    // each warp gets a shared block for one access to global memory
    __shared__ uint _sh_[THREADS_PER_BLOCK / WARP_SIZE * 128];
    uint *const _shared_ = &_sh_[threadIdx.y * 128];
    for (uint src = blockIdx.x * blockDim.x + threadIdx.y; src < n; src += blockDim.x * gridDim.x)
    {
        uint index = src * 32;
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
                if (numDstNodes)
                {
                    // go through all dst nodes, and union the out edges of that node w/ src's out nodes
                    for (size_t i = 0; i < numDstNodes; i++)
                    {
                        uint fromDstNode = _shared_[i];
                        uint fromIndex = fromDstNode * 32;
                        // read dst out edges
                        uint fromBits = B[fromIndex + threadIdx.x];
                        uint fromBase = B[fromIndex + BASE];
                        if (fromBase == UINT_MAX)
                            continue;

                        uint fromNext = B[fromIndex + NEXT];
                        uint toIndex = index;
                        uint toBits = C[toIndex + threadIdx.x];
                        uint toBase = C[toIndex + BASE];
                        uint toNext = C[toIndex + NEXT];

                        if (toBase == UINT_MAX)
                            C[toIndex + threadIdx.x] = fromBits;
                        while (1)
                        {
                            if (toBase == fromBase)
                            {
                                // if target next is undefined, create new edge for more edges
                                uint newToNext = (toNext == UINT_MAX && fromNext != UINT_MAX) ? incEdgeCouter() : toNext;
                                // union the bits, adding the new edge
                                uint orBits = fromBits | toBits;
                                uint newBits = threadIdx.x == NEXT ? newToNext : orBits;
                                if (newBits != toBits)
                                {
                                    C[toIndex + threadIdx.x] = newBits;
                                }
                                if (fromNext == UINT_MAX)
                                {
                                    break;
                                }
                                fromBits = C[fromNext + threadIdx.x];
                                fromBase = C[fromNext + BASE];
                                fromNext = C[fromNext + NEXT];
                                if (toNext == UINT_MAX)
                                {
                                    while (1)
                                    {
                                        uint newIndex = fromNext == UINT_MAX ? UINT_MAX : incEdgeCouter();
                                        uint val = threadIdx.x == NEXT ? newIndex : fromBits;
                                        C[toIndex + threadIdx.x] = val;
                                        if (fromNext == UINT_MAX)
                                        {
                                            break;
                                        }
                                        toIndex = newIndex;
                                        fromBits = C[fromNext + threadIdx.x];
                                        fromNext = C[fromNext + NEXT];
                                    }
                                    break;
                                }
                                toIndex = newToNext;
                                toBits = C[toNext + threadIdx.x];
                                toBase = C[toNext + BASE];
                                toNext = C[toNext + NEXT];
                            }
                        }
                    }
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

    // insertEdge(1, 0, pts);
    // insertEdge(2, 1, invLoad);
    // insertEdge(1, 3, invStore);
    // insertEdge(3, 4, pts);
    insertEdge(0, 1, invCopy);
    insertEdge(1, 2, pts);

    // num of vertices
    size_t V{3};

    uint numPtsElementsFree = V * ELEMENT_WIDTH;
    cudaMemcpyToSymbol(__ptsFreeList__, &numPtsElementsFree, sizeof(uint));

    dim3 numBlocks(16);
    dim3 threadsPerBlock(WARP_SIZE, THREADS_PER_BLOCK / WARP_SIZE);
    kernel<<<numBlocks, threadsPerBlock>>>(V, invCopy, pts, pts);

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