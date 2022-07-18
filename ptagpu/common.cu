#include "common.cuh"
#include <iostream>
#include <bitset>

/**
 * __ptsFreeList__
 * this is the head of the free list
 * keeps track of last allocated memory location
 * access needs to be atomic to prevent collisions
 *
 */
__device__ uint __ptsFreeList__;

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

__device__ uint incEdgeCouter()
{
    __shared__ volatile uint _shared_[THREADS_PER_BLOCK / WARP_SIZE];
    if (threadIdx.x == 0)
    {
        _shared_[threadIdx.y] = atomicAdd(&__ptsFreeList__, 32);
    }
    return _shared_[threadIdx.y];
}

__device__ uint insertEdgeDevice(uint src, uint dst, uint *graph)
{
    uint index = src * 32;
    uint base = BASE_OF(dst);
    uint word = WORD_OF(dst);
    uint bit = BIT_OF(dst);
    uint myBits = 0;

    if (threadIdx.x == word)
        myBits = 1 << bit;
    else if (threadIdx.x == BASE)
        myBits = base;
    else if (threadIdx.x == NEXT)
        myBits = UINT_MAX;

    while (1)
    {
        uint toBits = graph[index + threadIdx.x];
        uint toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
        if (toBase == UINT_MAX)
        {
            graph[index + threadIdx.x] = myBits;
            return index;
        }
        if (toBase == base)
        {
            uint orBits = toBits | myBits;
            if (orBits != toBits && threadIdx.x < NEXT)
                graph[index + threadIdx.x] = orBits;

            return index;
        }
        if (toBase < base)
        {
            uint toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);
            if (toNext == UINT_MAX)
            {
                uint newIndex = incEdgeCouter();
                uint val = threadIdx.x == NEXT ? newIndex : myBits;
                graph[newIndex + threadIdx.x] = val;
                return newIndex;
            }
            index = toNext;
        }
        else
        {
            uint newIndex = incEdgeCouter();
            graph[newIndex + threadIdx.x] = myBits;
            uint val = threadIdx.x == NEXT ? newIndex : myBits;
            graph[index + threadIdx.x] = val;
            return index;
        }
    }
}

/**
 * Basic function to insert edges into graph
 * This function is slow and running on the CPU
 * it is also assumed, that all edges have the same base and fit into the first word.
 * This is only for testing the kernel.
 */
__host__ void insertEdge(uint src, uint dst, uint *graph)
{
    uint index = src * 32;
    uint base = BASE_OF(dst);
    uint word = WORD_OF(dst);
    uint bit = BIT_OF(dst);

    while (1)
    {

        uint toBits = graph[index + word];
        uint toBase = graph[index + BASE];
        uint toNext = graph[index + NEXT];
    }
    if (graph[index + BASE] == UINT_MAX){
        for (size_t i = 0; i < ELEMENT_WIDTH - 2; i++)
            graph[index + i] = 0;
        graph[index + BASE] = base;
    }

    graph[index + word] |= 1 << bit;
}

__device__ void insertBitvector(uint *originMemory, uint *targetMemory, uint toIndex, uint fromBits)
{
    while (1)
    {
        // use warp intrinsics to get next index in from memory
        uint fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
        // check if a new bitvector is required
        // if that is the case, allocate a new index for a new element
        uint toNext = fromNext == UINT_MAX ? UINT_MAX : incEdgeCouter();
        // handle the special next entry, since we can not reuse the fromNext bits
        uint val = threadIdx.x == NEXT ? toNext : fromBits;
        // write new values to target memory location
        targetMemory[toIndex + threadIdx.x] = val;
        // exit if no more elements in from bitvector
        if (fromNext == UINT_MAX)
            return;
        toIndex = toNext;
        fromBits = originMemory[fromNext + threadIdx.x];
    }
}

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
            uint base = __shfl_sync(0xFFFFFFFF, bits, 30);
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
                        uint fromIndex = _shared_[i] * 32;
                        // read dst out edges
                        uint fromBits = B[fromIndex + threadIdx.x];
                        // get the base from thread nr 30
                        uint fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
                        // terminate if no data in from from bitvector
                        if (fromBase == UINT_MAX)
                            continue;
                        // get the next index from thread nr 31
                        uint fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);

                        // share needed data for to indices
                        uint toIndex = index;
                        uint toBits = C[toIndex + threadIdx.x];
                        uint toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
                        uint toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);

                        if (toBase == UINT_MAX)
                            insertBitvector(B, C, toIndex, fromBits);
                        break;
                        while (1)
                        {
                            if (toBase == fromBase)
                            {
                                // if target next is undefined, create new edge for more edges
                                uint newToNext = (toNext == UINT_MAX && fromNext != UINT_MAX) ? incEdgeCouter() : toNext;
                                // union the bits, adding the new edges
                                uint orBits = fromBits | toBits;
                                // each thread gets a value that will be written back to memory
                                uint val = threadIdx.x == NEXT ? newToNext : orBits;
                                if (val != toBits)
                                {
                                    C[toIndex + threadIdx.x] = val;
                                }

                                // if no more bitvectors in origin, end loop
                                if (fromNext == UINT_MAX)
                                {
                                    break;
                                }
                                // else load next bits
                                fromBits = C[fromNext + threadIdx.x];
                                fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
                                fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
                                if (toNext == UINT_MAX)
                                {
                                    insertBitvector(B, C, toIndex, fromBits);
                                    break;
                                }
                                toIndex = newToNext;
                                toBits = C[toNext + threadIdx.x];
                                toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
                                toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);
                            }
                            else if (toBase < fromBase)
                            {
                                // if toNext is undefined, we need to allocate a new element
                                // after that, we can simply insert teh origin bitvector
                                if (toNext == UINT_MAX)
                                {
                                    toNext = incEdgeCouter();
                                    insertBitvector(B, C, toNext, fromBits);
                                    break;
                                }
                                // if toNext is defined, load those to bits for the next iteration
                                toIndex = toNext;
                                toBits = C[toNext + threadIdx.x];
                                toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
                                toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);
                            }
                            else if (toBase > fromBase)
                            {
                                // if toBase is greater than frombase
                                // we need to insert enother bitvector element before toindex
                                // and shift the current element back (ref. linked lists)
                                uint newIndex = incEdgeCouter();
                                // write the current bits from the target element to a new location
                                C[newIndex + threadIdx.x] = toBits;
                                // then overwrite the current bits with fromBits (insert before node)
                                uint val = threadIdx.x == NEXT ? newIndex : fromBits;
                                C[toIndex + threadIdx.x] = val;

                                // if next from element is defined, update the bits
                                if (fromNext == UINT_MAX)
                                    return;

                                toIndex = newIndex;

                                fromBits = C[fromNext + threadIdx.x];
                                fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
                                fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
                            }
                        }
                    }
                }
            }
            index = __shfl_sync(0xFFFFFFFF, bits, 31);
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

    // num of vertices
    size_t V{3};

    // insertEdge(1, 0, pts);
    // insertEdge(2, 1, invLoad);
    // insertEdge(1, 3, invStore);
    // insertEdge(3, 4, pts);
    numElements = V;
    insertEdge(0, 1, invCopy);
    insertEdge(1, 2, pts);

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