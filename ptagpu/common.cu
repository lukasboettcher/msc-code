#include "common.cuh"

std::map<unsigned int *, unsigned int> testMap;

/**
 * __ptsFreeList__
 * this is the head of the free list
 * keeps track of last allocated memory location
 * access needs to be atomic to prevent collisions
 *
 */
__device__ uint __freeList__[N_TYPES];

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

__device__ uint incEdgeCouter(int type)
{
    __shared__ volatile uint _shared_[THREADS_PER_BLOCK / WARP_SIZE];
    if (threadIdx.x == 0)
    {
        _shared_[threadIdx.y] = atomicAdd(&__freeList__[type], 32);
    }
    return _shared_[threadIdx.y];
}

__device__ uint insertEdgeDevice(uint src, uint dst, uint *graph, uint toRel)
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
                uint newIndex = incEdgeCouter(toRel);
                graph[index + NEXT] = newIndex;
                graph[newIndex + threadIdx.x] = myBits;
                return newIndex;
            }
            index = toNext;
        }
        else
        {
            uint newIndex = incEdgeCouter(toRel);
            graph[newIndex + threadIdx.x] = toBits;
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
    // printf("inserting edge %u -> %u\n\tindex: %u\n\tbase: %u\n\tword: %u\n\tbit: %u\n", src, dst, index, base, word, bit);

    if (graph[index + BASE] == UINT_MAX)
    {
        for (size_t i = 0; i < ELEMENT_WIDTH - 2; i++)
            graph[index + i] = 0;
        graph[index + BASE] = base;
        graph[index + word] |= 1 << bit;
        return;
    }

    while (1)
    {
        uint toBase = graph[index + BASE];
        uint toNext = graph[index + NEXT];

        if (toBase == UINT_MAX)
        {
            for (size_t i = 0; i < ELEMENT_WIDTH - 2; i++)
                graph[index + i] = 0;
            graph[index + BASE] = base;
            graph[index + word] |= 1 << bit;
            return;
        }
        if (toBase < base)
        {
            if (toNext == UINT_MAX)
            {
                uint nextIndex = ++testMap[graph] * 32;
                graph[index + NEXT] = nextIndex;

                for (size_t i = 0; i < ELEMENT_WIDTH - 2; i++)
                    graph[nextIndex + i] = 0;
                graph[nextIndex + BASE] = base;
                graph[nextIndex + word] |= 1 << bit;

                return;
            }

            index = toNext;
        }
        else if (base == toBase)
        {
            graph[index + word] |= 1 << bit;
            return;
        }
        else if (toBase > base)
        {

            uint nextIndex = ++testMap[graph] * 32;
            for (size_t i = 0; i < ELEMENT_WIDTH; i++)
                graph[nextIndex + i] = graph[index + i];
            for (size_t i = 0; i < ELEMENT_WIDTH - 2; i++)
                graph[nextIndex + i] = 0;
            graph[index + BASE] = base;
            graph[index + NEXT] = nextIndex;
            graph[index + word] |= 1 << bit;
        }
    }
}

__device__ void insertBitvector(uint *originMemory, uint *targetMemory, uint toIndex, uint fromBits, uint toRel)
{
    while (1)
    {
        // use warp intrinsics to get next index in from memory
        uint fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
        // check if a new bitvector is required
        // if that is the case, allocate a new index for a new element
        uint toNext = fromNext == UINT_MAX ? UINT_MAX : incEdgeCouter(toRel);
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

__device__ void mergeBitvectors(uint *A, uint *B, uint *C, uint index, uint numDstNodes, uint *const _shared_, uint toRel)
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
        {
            insertBitvector(B, C, toIndex, fromBits, toRel);
            continue;
        }

        while (1)
        {
            if (toBase == fromBase)
            {
                // if target next is undefined, create new edge for more edges
                uint newToNext = (toNext == UINT_MAX && fromNext != UINT_MAX) ? incEdgeCouter(toRel) : toNext;
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
                    insertBitvector(B, C, toIndex, fromBits, toRel);
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
                    toNext = incEdgeCouter(toRel);
                    insertBitvector(B, C, toNext, fromBits, toRel);
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
                uint newIndex = incEdgeCouter(toRel);
                // write the current bits from the target element to a new location
                C[newIndex + threadIdx.x] = toBits;
                // then overwrite the current bits with fromBits (insert before node)
                uint val = threadIdx.x == NEXT ? newIndex : fromBits;
                C[toIndex + threadIdx.x] = val;

                // if next from element is defined, update the bits
                // if not, break for this element
                if (fromNext == UINT_MAX)
                    break;

                toIndex = newIndex;

                fromBits = C[fromNext + threadIdx.x];
                fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
                fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
            }
        }
    }
}

__global__ void kernel(int n, uint *A, uint *B, uint *C, uint toRel)
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
                    mergeBitvectors(A, B, C, index, numDstNodes, _shared_, toRel);
                }
            }
            index = __shfl_sync(0xFFFFFFFF, bits, 31);
        } while (index != UINT_MAX);
    }
}

__device__ uint store_map_head = 0;

__device__ void insert_store_map(const uint src, const uint n, uint *const list, uint *store_map_pts, uint *store_map_src)
{
    for (int i = 0; i < n; i += 32)
    {
        uint size = min(n - i, 32);
        uint next;
        if (!threadIdx.x)
        {
            next = atomicAdd(&store_map_head, size);
        }
        next = __shfl_sync(0xFFFFFFFF, next, 0);
        if (threadIdx.x < size)
        {
            store_map_pts[next + threadIdx.x] = list[i + threadIdx.x];
            // store_map_src[next + threadIdx.x] = src_index;
            store_map_src[next + threadIdx.x] = src;
        }
    }
}

/**
 * Kernel for store edges,
 * here we need to collect all store edges that share a pts edge
 * and selectively assign them to the same warps
 * so that we save on synchronization between warps
 */
__global__ void kernel_store(int n, uint *A, uint *B, uint *C)
{
    // each warp gets a shared block for one access to global memory
    __shared__ uint _sh_[THREADS_PER_BLOCK / WARP_SIZE * 128];
    uint *const _shared_ = &_sh_[threadIdx.y * 128];
    for (uint src = blockIdx.x * blockDim.x + threadIdx.y; src < n; src += blockDim.x * gridDim.x)
    {
        uint index = src * 32;
        uint usedShared = 0;
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
                if (usedShared + numDstNodes > 128)
                {
                    insert_store_map(index, usedShared, _shared_, B, C);
                    usedShared = 0;
                }
                // calculate pos in shared mem, by counting prev threads that had a dst node
                uint pos = usedShared + __popc(threadsWithDstNode & myMask);
                if (bitActive)
                {
                    _shared_[pos] = var;
                }
                usedShared += numDstNodes;
            }
            index = __shfl_sync(0xFFFFFFFF, bits, 31);
        } while (index != UINT_MAX);
        if (usedShared)
        {
            insert_store_map(src, usedShared, _shared_, B, C);
        }
    }
}

__global__ void kernel_store2copy(const uint n, uint *store_map_pts, uint *store_map_src, uint *store_map_idx, uint *pts, uint *store, uint *invCopy, uint toRel)
{
    __shared__ uint _sh_[THREADS_PER_BLOCK / WARP_SIZE * 128];
    uint *const _shared_ = &_sh_[threadIdx.y * 128];
    for (uint i = blockIdx.x * blockDim.x + threadIdx.y; i < n - 1; i += blockDim.x * gridDim.x)
    {
        uint idx = store_map_idx[i];
        uint idx_next = store_map_idx[i + 1];

        // load the pts target, this should no change for the next totalDstNodes
        uint pts_target = store_map_pts[idx];

        for (uint j = idx; j < idx_next; j += 32)
        {
            uint numDstNodes = min(idx_next - j, 32U);
            if (j + threadIdx.x < idx_next)
            {
                _shared_[threadIdx.x] = store_map_src[j + threadIdx.x];
            }
            mergeBitvectors(pts, store, invCopy, pts_target * 32, numDstNodes, _shared_, toRel);
        }
    }
}

__global__ void kernel_insert_edges(const uint n, uint *from, uint *to, uint *ofst, uint *memory, int rel)
{
    int index = blockIdx.x * blockDim.x + threadIdx.y;
    int stride = blockDim.x * gridDim.x;
    for (int i = index; i < n; i += stride)
    {

        uint offset = ofst[i];
        uint offset_next = ofst[i + 1];
        uint src = from[offset];

        for (size_t j = offset; j < offset_next; j++)
        {
            uint dst = to[j];
            insertEdgeDevice(src, dst, memory, rel);
        }
    }
}

__host__ void insertEdges(edgeSet *edges, uint *memory, int inv, int rel)
{
    uint *from, *to, *ofst, N;

    N = edges->second.size();

    checkCuda(cudaMallocManaged(&from, N * sizeof(unsigned int)));
    checkCuda(cudaMallocManaged(&to, N * sizeof(unsigned int)));
    checkCuda(cudaMallocManaged(&ofst, N * sizeof(unsigned int)));

    if (inv)
    {
        memcpy(from, edges->second.data(), N * sizeof(unsigned int));
        memcpy(to, edges->first.data(), N * sizeof(unsigned int));
    }
    else
    {
        memcpy(from, edges->first.data(), N * sizeof(unsigned int));
        memcpy(to, edges->second.data(), N * sizeof(unsigned int));
    }

    thrust::sort_by_key(thrust::device, from, from + N, to);
    long numUnique = thrust::unique_by_key_copy(thrust::device, from, from + N, thrust::make_counting_iterator(0), thrust::make_discard_iterator(), ofst).second - ofst;

    // CUDA kernel to add elements of two arrays

    dim3 numBlocks(16);
    dim3 threadsPerBlock(WARP_SIZE, THREADS_PER_BLOCK / WARP_SIZE);

    checkCuda(cudaDeviceSynchronize());
    kernel_insert_edges<<<numBlocks, threadsPerBlock>>>(numUnique, from, to, ofst, memory, rel);
    checkCuda(cudaDeviceSynchronize());

    checkCuda(cudaFree(from));
    checkCuda(cudaFree(to));
    checkCuda(cudaFree(ofst));
}

__host__ int run(unsigned int numNodes, edgeSet *addrEdges, edgeSet *directEdges, edgeSet *loadEdges, edgeSet *storeEdges, edgeSetOffset *gepEdges)
{
    int N = 1 << 28;
    uint *pts, *prevPtsDiff, *currPtsDiff, *invCopy, *invStore, *invLoad, *store_map_pts, *store_map_src, *store_map_idx;

    // Allocate Unified Memory -- accessible from CPU or GPU
    checkCuda(cudaMallocManaged(&pts, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&prevPtsDiff, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&currPtsDiff, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invCopy, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invStore, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invLoad, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&store_map_pts, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&store_map_src, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&store_map_idx, N * sizeof(uint1)));

    // set all values to UINT_MAX
    cudaMemset(pts, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(prevPtsDiff, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(currPtsDiff, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(invCopy, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(invStore, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(invLoad, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(store_map_pts, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(store_map_src, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(store_map_idx, UCHAR_MAX, N * sizeof(unsigned int));

    // num of vertices
    size_t V{numNodes};

    // reserve 20% for new edges added by gep offsets
    uint initNum = std::ceil(1.2 * V) * ELEMENT_WIDTH;
    uint freeList[N_TYPES] = {initNum, initNum, initNum, initNum, initNum};
    checkCuda(cudaMemcpyToSymbol(__freeList__, freeList, N_TYPES * sizeof(uint), 0, cudaMemcpyHostToDevice));

    insertEdges(addrEdges, pts, 1, PTS);
    insertEdges(directEdges, invCopy, 1, COPY);
    insertEdges(loadEdges, invLoad, 1, LOAD);
    insertEdges(storeEdges, invStore, 1, STORE);

    for (size_t i = 0; i < 10; i++)
    {
        dim3 numBlocks(16);
        dim3 threadsPerBlock(WARP_SIZE, THREADS_PER_BLOCK / WARP_SIZE);
        kernel<<<numBlocks, threadsPerBlock>>>(V, invCopy, pts, pts, PTS);
        checkCuda(cudaDeviceSynchronize());
        kernel<<<numBlocks, threadsPerBlock>>>(V, invLoad, pts, invCopy, COPY);

        checkCuda(cudaDeviceSynchronize());
        kernel_store<<<numBlocks, threadsPerBlock>>>(V, pts, store_map_pts, store_map_src);
        checkCuda(cudaDeviceSynchronize());

        thrust::sort_by_key(thrust::device, store_map_pts, store_map_pts + N, store_map_src);
        auto numSrcs = thrust::unique_by_key_copy(thrust::device, store_map_pts, store_map_pts + N, thrust::make_counting_iterator(0), thrust::make_discard_iterator(), store_map_idx).second - store_map_idx;


        checkCuda(cudaDeviceSynchronize());
        kernel_store2copy<<<numBlocks, threadsPerBlock>>>(numSrcs, store_map_pts, store_map_src, store_map_idx, pts, invStore, invCopy, COPY);
        checkCuda(cudaDeviceSynchronize());
    }
    // Free memory
    checkCuda(cudaFree(pts));
    checkCuda(cudaFree(prevPtsDiff));
    checkCuda(cudaFree(currPtsDiff));
    checkCuda(cudaFree(invCopy));
    checkCuda(cudaFree(invStore));
    checkCuda(cudaFree(invLoad));
    checkCuda(cudaFree(store_map_pts));
    checkCuda(cudaFree(store_map_src));
    checkCuda(cudaFree(store_map_idx));

    return 0;
}