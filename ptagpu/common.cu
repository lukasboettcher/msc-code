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
 * flag that keeps track of remaining work
 * if true, no next iteration needed
 *
 */
__device__ bool __done__ = true;

/**
 * device pointers for the pts bitvectors
 * these need to be accesses adhoc
 * so are written to device symbols permanently
 *
 */
__device__ uint *__pts__;
__device__ uint *__ptsCurr__;
__device__ uint *__ptsNext__;

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

__device__ void collectBitvectorTargets(const uint index, const uint bits, const uint base, uint *storage, uint &usedStorage, uint *originMemory, uint *targetMemory, const uint toRel);

__device__ void insertBitvector(const uint index, const uint *originMemory, uint *targetMemory, uint *storage, uint &usedStorage, uint toIndex, uint fromBits, uint toRel)
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

        if (toRel == COPY)
        {
            uint fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
            collectBitvectorTargets(index, fromBits, fromBase, storage + 128, usedStorage, __pts__, __ptsNext__, PTS_NEXT);
        }

        // exit if no more elements in from bitvector
        if (fromNext == UINT_MAX)
            return;
        toIndex = toNext;
        fromBits = originMemory[fromNext + threadIdx.x];
    }
}

__device__ void mergeBitvectors(const uint *origin, uint *target, const uint index, const uint numDstNodes, uint *_shared_, const uint toRel)
{
    // go through all dst nodes, and union the out edges of that node w/ src's out nodes
    for (size_t i = 0; i < numDstNodes; i++)
    {
        uint fromIndex = _shared_[i] * 32;
        // read dst out edges
        uint fromBits = origin[fromIndex + threadIdx.x];
        // get the base from thread nr 30
        uint fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
        // terminate if no data in from from bitvector
        if (fromBase == UINT_MAX)
            continue;
        // get the next index from thread nr 31
        uint fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);

        // share needed data for to indices
        uint toIndex = index;
        uint toBits = target[toIndex + threadIdx.x];
        uint toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
        uint toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);

        uint runloop = 1;

        if (toBase == UINT_MAX)
        {
            insertBitvector(origin, target, toIndex, fromBits, toRel);
            runloop = 0;
        }

        while (runloop)
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
                    target[toIndex + threadIdx.x] = val;
                }

                // if no more bitvectors in origin, end loop
                if (fromNext == UINT_MAX)
                {
                    break;
                }
                // else load next bits
                fromBits = origin[fromNext + threadIdx.x];
                fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
                fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
                if (toNext == UINT_MAX)
                {
                    insertBitvector(origin, target, toIndex, fromBits, toRel);
                    break;
                }
                toIndex = newToNext;
                toBits = target[toNext + threadIdx.x];
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
                    insertBitvector(origin, target, toNext, fromBits, toRel);
                    break;
                }
                // if toNext is defined, load those to bits for the next iteration
                toIndex = toNext;
                toBits = target[toNext + threadIdx.x];
                toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
                toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);
            }
            else if (toBase > fromBase)
            {
                // if toBase is greater than frombase
                // we need to insert another bitvector element before toindex
                // and shift the current element back (ref. linked lists)
                uint newIndex = incEdgeCouter(toRel);
                // write the current bits from the target element to a new location
                target[newIndex + threadIdx.x] = toBits;
                // then overwrite the current bits with fromBits (insert before node)
                uint val = threadIdx.x == NEXT ? newIndex : fromBits;
                target[toIndex + threadIdx.x] = val;

                // if next from element is defined, update the bits
                // if not, break for this element
                if (fromNext == UINT_MAX)
                    break;

                toIndex = newIndex;

                fromBits = origin[fromNext + threadIdx.x];
                fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
                fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
            }
        }
    }
}

__device__ void collectBitvectorTargets(const uint index, const uint bits, const uint base, uint *storage, uint &usedStorage, uint *originMemory, uint *targetMemory, const uint toRel)
{
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
        if (usedStorage + numDstNodes > 128)
        {
            // insert_store_map(index, usedStorage, storage, originMemory, targetMemory);
            mergeBitvectors(originMemory, targetMemory, index, numDstNodes, storage, toRel);
            usedStorage = 0;
        }
        // calculate pos in shared mem, by counting prev threads that had a dst node
        uint pos = usedStorage + __popc(threadsWithDstNode & myMask);
        if (bitActive)
        {
            storage[pos] = var;
        }
        usedStorage += numDstNodes;
    }
}

__global__ void kernel(int n, uint *A, uint *B, uint *C, uint toRel)
{
    // each warp gets a shared block for one access to global memory
    __shared__ uint _sh_[THREADS_PER_BLOCK / WARP_SIZE * 256];
    uint *const _shared_ = &_sh_[threadIdx.y * 256];
    uint usedShared = 0;
    for (uint src = blockIdx.x * blockDim.y + threadIdx.y; src < n; src += blockDim.y * gridDim.x)
    {
        uint index = src * 32;
        do
        {
            uint bits = A[index + threadIdx.x];
            uint base = __shfl_sync(0xFFFFFFFF, bits, 30);
            if (base == UINT_MAX)
                break;

            collectBitvectorTargets(src * 32, bits, base, _shared_, usedShared, B, C, toRel);
            index = __shfl_sync(0xFFFFFFFF, bits, 31);
        } while (index != UINT_MAX);
        if (usedShared)
        {
            mergeBitvectors(B, C, src * 32, usedShared, _shared_, toRel);
        }
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
    for (uint src = blockIdx.x * blockDim.y + threadIdx.y; src < n; src += blockDim.y * gridDim.x)
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
    __shared__ uint _sh_[THREADS_PER_BLOCK / WARP_SIZE * 256];
    uint *const _shared_ = &_sh_[threadIdx.y * 256];
    for (uint i = blockIdx.x * blockDim.y + threadIdx.y; i < n - 1; i += blockDim.y * gridDim.x)
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
            mergeBitvectors(store, invCopy, pts_target * 32, numDstNodes, _shared_, toRel);
        }
    }
}

__global__ void kernel_insert_edges(const uint n, uint *from, uint *to, uint *ofst, uint *memory, int rel)
{
    int index = blockIdx.x * blockDim.y + threadIdx.y;
    int stride = blockDim.y * gridDim.x;
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

    dim3 numBlocks(N_BLOCKS);
    dim3 threadsPerBlock(WARP_SIZE, THREADS_PER_BLOCK / WARP_SIZE);

    checkCuda(cudaDeviceSynchronize());
    kernel_insert_edges<<<numBlocks, threadsPerBlock>>>(numUnique, from, to, ofst, memory, rel);
    checkCuda(cudaDeviceSynchronize());

    checkCuda(cudaFree(from));
    checkCuda(cudaFree(to));
    checkCuda(cudaFree(ofst));
}

/**
 * collect pts targets for src
 */
__host__ void collectFromBitvector(uint src, uint *memory, std::vector<uint> &pts)
{
    uint index = src * 32;
    uint base, next, bits, ptsTarget;

    while (index != UINT_MAX)
    {
        base = memory[index + BASE];
        next = memory[index + NEXT];

        if (base == UINT_MAX)
        {
            break;
        }

        for (size_t j = 0; j < BASE; j++)
        {
            bits = memory[index + j];
            for (size_t k = 0; k < 32; k++)
            {
                if (1 << k & bits)
                {
                    // calculate target from bitvector
                    ptsTarget = 960 * base + 32 * j + k;
                    pts.push_back(ptsTarget);
                }
            }
        }
        index = next;
    }
}

__host__ uint handleGepEdges(edgeSetOffset *gepEdges, uint *memory, void *consG, void *pag)
{
    for (size_t i = 0; i < gepEdges->second.size(); i++)
    {
        uint src, dst, offset, gepElement;
        src = gepEdges->first.first[i];
        offset = gepEdges->first.second[i];
        dst = gepEdges->second[i];

        std::vector<uint> targets;
        collectFromBitvector(src, memory, targets);
        for (uint target : targets)
        {
            gepElement = handleGep(consG, pag, target, offset);
            insertEdge(gepElement, dst, memory);
        }
    }
    uint nodeCount = getNodeCount(consG);
    return nodeCount;
}

__host__ bool alias(uint a, uint b, uint *memory)
{
    std::vector<uint> ptsA, ptsB;

    collectFromBitvector(a, memory, ptsA);
    collectFromBitvector(b, memory, ptsB);

    for (uint target : ptsA)
        if (std::find(ptsB.begin(), ptsB.end(), target) != ptsB.end())
            return true;

    return false;
}

__device__ void cloneAndLink(const uint var, const uint ptsIndex, uint &currDiffPtsIndex, const uint diffPtsBits, const uint diffPtsNext, uint *pts, uint *curr_pts, uint *next_pts)
{
    // clone(ptsIndex, diffPtsBits, diffPtsNext, PTS);
    insertBitvector(next_pts, pts, ptsIndex, diffPtsBits, PTS);
    if (currDiffPtsIndex != UINT_MAX)
    {
        curr_pts[currDiffPtsIndex + NEXT] = ptsIndex;
    }
    else
    {
        currDiffPtsIndex = 32 * var;
        uint ptsBits = pts[ptsIndex + threadIdx.x];
        curr_pts[currDiffPtsIndex + threadIdx.x] = ptsBits;
    }
}

/**
 * Update the current, next and total PTS sets of a variable. In the last iteration of the main
 * loop, points-to edges have been added to NEXT_DIFF_PTS. However, many of them might already be
 * present in PTS. The purpose of this function is to update PTS as PTS U NEXT_DIFF_PTS, and set
 * CURR_DIFF_PTS as the difference between the old and new PTS for the given variable.
 *
 * @param var ID of the variable
 * @param pts memory for all points to bitvectors
 * @param curr_pts memory for previous iterations points to bitvectors in working set
 * @param next_pts memory for all newly added pts bitvectors
 * @return true if new pts edges have been added to this variable
 */
__device__ bool updatePtsAndDiffPts(const uint var, uint *pts, uint *curr_pts, uint *next_pts)
{
    // next next index
    const uint diffPtsHeadIndex = var * 32;

    uint diffPtsBits = next_pts[diffPtsHeadIndex + threadIdx.x];
    uint diffPtsBase = __shfl_sync(0xFFFFFFFF, diffPtsBits, 30);

    if (diffPtsBase == UINT_MAX)
    {
        return false;
    }

    uint diffPtsNext = __shfl_sync(0xFFFFFFFF, diffPtsBits, 31);
    next_pts[diffPtsHeadIndex + threadIdx.x] = UINT_MAX;

    uint ptsIndex = var * 32;
    uint ptsBits = pts[ptsIndex + threadIdx.x];
    uint ptsBase = __shfl_sync(0xFFFFFFFF, ptsBits, 30);

    if (ptsBase == UINT_MAX)
    {
        // we pass ptsBase instead of UINT_MAX because it's also UINT_MAX but it can be modified
        cloneAndLink(var, ptsIndex, ptsBase, diffPtsBits, diffPtsNext, pts, curr_pts, next_pts);
        return true;
    }
    uint ptsNext = __shfl_sync(0xFFFFFFFF, ptsBits, 31);
    uint currDiffPtsIndex = UINT_MAX;
    while (1)
    {
        if (ptsBase > diffPtsBase)
        {
            uint newIndex = incEdgeCouter(PTS);
            pts[newIndex + threadIdx.x] = ptsBits;
            uint val = threadIdx.x == NEXT ? newIndex : diffPtsBits;
            pts[ptsIndex + threadIdx.x] = val;

            ptsIndex = newIndex;
            // update CURR_DIFF_PTS
            newIndex = currDiffPtsIndex == UINT_MAX ? 32 * var : incEdgeCouter(PTS_CURR);
            val = threadIdx.x == NEXT ? UINT_MAX : diffPtsBits;
            curr_pts[newIndex + threadIdx.x] = val;
            if (currDiffPtsIndex != UINT_MAX)
            {
                curr_pts[currDiffPtsIndex + NEXT] = newIndex;
            }
            if (diffPtsNext == UINT_MAX)
            {
                return true;
            }
            currDiffPtsIndex = newIndex;

            diffPtsBits = next_pts[diffPtsNext + threadIdx.x];
            diffPtsBase = __shfl_sync(0xFFFFFFFF, diffPtsBits, 30);
            diffPtsNext = __shfl_sync(0xFFFFFFFF, diffPtsBits, 31);
        }
        else if (ptsBase == diffPtsBase)
        {
            uint newPtsNext = (ptsNext == UINT_MAX && diffPtsNext != UINT_MAX) ? incEdgeCouter(PTS) : ptsNext;
            uint orBits = threadIdx.x == NEXT ? newPtsNext : ptsBits | diffPtsBits;
            uint ballot = __ballot_sync(0x3FFFFFFF, orBits != ptsBits);
            pts[ptsIndex + threadIdx.x] = orBits;
            if (ballot)
            {
                // update CURR_DIFF_PTS
                orBits = diffPtsBits & ~ptsBits;
                if (threadIdx.x == BASE)
                {
                    orBits = ptsBase;
                }
                else if (threadIdx.x == NEXT)
                {
                    orBits = UINT_MAX;
                }
                uint newIndex;
                if (currDiffPtsIndex != UINT_MAX)
                {

                    newIndex = incEdgeCouter(PTS_CURR);
                    curr_pts[currDiffPtsIndex + NEXT] = newIndex;
                }
                else
                {
                    newIndex = var * 32;
                }
                curr_pts[newIndex + threadIdx.x] = orBits;
                currDiffPtsIndex = newIndex;
            }
            if (diffPtsNext == UINT_MAX)
            {
                return (currDiffPtsIndex != UINT_MAX);
            }
            diffPtsBits = next_pts[diffPtsNext + threadIdx.x];
            diffPtsBase = __shfl_sync(0xFFFFFFFF, diffPtsBits, 30);
            diffPtsNext = __shfl_sync(0xFFFFFFFF, diffPtsBits, 31);

            if (ptsNext == UINT_MAX)
            {
                cloneAndLink(var, newPtsNext, currDiffPtsIndex, diffPtsBits, diffPtsNext, pts, curr_pts, next_pts);
                return true;
            }
            ptsIndex = ptsNext;

            ptsBits = pts[ptsIndex + threadIdx.x];
            ptsBase = __shfl_sync(0xFFFFFFFF, ptsBits, 30);
            ptsNext = __shfl_sync(0xFFFFFFFF, ptsBits, 31);
        }
        else
        { // ptsBase > diffPtsBase
            if (ptsNext == UINT_MAX)
            {
                uint newPtsIndex = incEdgeCouter(PTS);
                pts[ptsIndex + NEXT] = newPtsIndex;
                cloneAndLink(var, newPtsIndex, currDiffPtsIndex, diffPtsBits, diffPtsNext, pts, curr_pts, next_pts);
                return true;
            }
            ptsIndex = ptsNext;
            ptsBits = pts[ptsIndex + threadIdx.x];
            ptsBase = __shfl_sync(0xFFFFFFFF, ptsBits, 30);
            ptsNext = __shfl_sync(0xFFFFFFFF, ptsBits, 31);
        }
    }
}

__global__ void kernel_updatePts(const uint n, uint *pts, uint *curr_pts, uint *next_pts)
{
    if (__pts__ != pts)
    {
        __pts__ = pts;
        __ptsCurr__ = curr_pts;
        __ptsNext__ = next_pts;
    }

    __done__ = true;
    bool newWork = false;
    for (uint i = blockIdx.x * blockDim.y + threadIdx.y; i < n - 1; i += blockDim.y * gridDim.x)
    {
        bool newStuff = updatePtsAndDiffPts(i, pts, curr_pts, next_pts);
        newWork |= newStuff;
        if (!newStuff)
        {
            const uint currPtsHeadIndex = 32 * i;
            curr_pts[currPtsHeadIndex + threadIdx.x] = UINT_MAX;
        }
    }
    if (newWork)
    {
        __done__ = false;
    }
    __syncthreads();
    __freeList__[PTS_CURR] = n * 32;
    __freeList__[PTS_NEXT] = n * 32;
}

__host__ int run(unsigned int numNodes, edgeSet *addrEdges, edgeSet *directEdges, edgeSet *loadEdges, edgeSet *storeEdges, edgeSetOffset *gepEdges, void *consG, void *pag)
{
    int N = 1 << 28;
    uint *pts, *currPtsDiff, *nextPtsDiff, *invCopy, *invStore, *invLoad, *store_map_pts, *store_map_src, *store_map_idx;

    // Allocate Unified Memory -- accessible from CPU or GPU
    checkCuda(cudaMallocManaged(&pts, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&currPtsDiff, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&nextPtsDiff, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invCopy, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invStore, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&invLoad, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&store_map_pts, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&store_map_src, N * sizeof(uint1)));
    checkCuda(cudaMallocManaged(&store_map_idx, N * sizeof(uint1)));

    // set all values to UINT_MAX
    cudaMemset(pts, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(currPtsDiff, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(nextPtsDiff, UCHAR_MAX, N * sizeof(unsigned int));
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
    uint freeList[N_TYPES] = {initNum, initNum, initNum, initNum, initNum, initNum, initNum};
    checkCuda(cudaMemcpyToSymbol(__freeList__, freeList, N_TYPES * sizeof(uint), 0, cudaMemcpyHostToDevice));

    insertEdges(addrEdges, nextPtsDiff, 1, PTS_NEXT);
    insertEdges(directEdges, invCopy, 1, COPY);
    insertEdges(loadEdges, invLoad, 1, LOAD);
    insertEdges(storeEdges, invStore, 1, STORE);

    while (0)
    {
        dim3 numBlocks(N_BLOCKS);
        dim3 threadsPerBlock(WARP_SIZE, THREADS_PER_BLOCK / WARP_SIZE);

        kernel_updatePts<<<numBlocks, threadsPerBlock>>>(V, pts, currPtsDiff, nextPtsDiff);
        checkCuda(cudaDeviceSynchronize());

        bool done = true;
        checkCuda(cudaMemcpyFromSymbol(&done, __done__, sizeof(bool)));

        if (done)
        {
            break;
        }
        kernel<<<numBlocks, threadsPerBlock>>>(V, invCopy, currPtsDiff, nextPtsDiff, PTS_NEXT);
        checkCuda(cudaDeviceSynchronize());
        kernel<<<numBlocks, threadsPerBlock>>>(V, invLoad, currPtsDiff, invCopy, COPY);

        checkCuda(cudaDeviceSynchronize());
        kernel_store<<<numBlocks, threadsPerBlock>>>(V, currPtsDiff, store_map_pts, store_map_src);
        checkCuda(cudaDeviceSynchronize());

        thrust::sort_by_key(thrust::device, store_map_pts, store_map_pts + N, store_map_src);
        auto numSrcs = thrust::unique_by_key_copy(thrust::device, store_map_pts, store_map_pts + N, thrust::make_counting_iterator(0), thrust::make_discard_iterator(), store_map_idx).second - store_map_idx;


        checkCuda(cudaDeviceSynchronize());
        kernel_store2copy<<<numBlocks, threadsPerBlock>>>(numSrcs, store_map_pts, store_map_src, store_map_idx, pts, invStore, invCopy, COPY);
        checkCuda(cudaDeviceSynchronize());
    }
    // Free memory
    checkCuda(cudaFree(pts));
    checkCuda(cudaFree(currPtsDiff));
    checkCuda(cudaFree(nextPtsDiff));
    checkCuda(cudaFree(invCopy));
    checkCuda(cudaFree(invStore));
    checkCuda(cudaFree(invLoad));
    checkCuda(cudaFree(store_map_pts));
    checkCuda(cudaFree(store_map_src));
    checkCuda(cudaFree(store_map_idx));

    return 0;
}