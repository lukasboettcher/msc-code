#include "common.cuh"

/**
 * __ptsFreeList__
 * this is the head of the free list
 * keeps track of last allocated memory location
 * access needs to be atomic to prevent collisions
 *
 */
__device__ __managed__ uint __freeList__[N_TYPES];

/**
 * __reservedHeader__
 *
 * this variable represents to max number of nodes
 *
 * is to be initialized with enough overhead
 * to allow adding further nodes via gep offsets calculations
 *
 */
__device__ __managed__ uint __reservedHeader__;

/**
 * flag that keeps track of remaining work
 * if true, no next iteration needed
 *
 */
__device__ __managed__ bool __done__ = true;

__device__ __managed__ uint *__key__;
__device__ __managed__ uint *__val__;
__device__ __managed__ uint *__keyAux__;

__device__ uint __numKeys__;

__device__ __managed__ uint __counter__ = 0;

__device__ uint __worklistIndex0__ = 0;
__device__ uint __worklistIndex1__ = 0;

__device__ uint __storeMapHead__ = 0;

/**
 * device pointers for the pts bitvectors
 * these need to be accesses adhoc
 * so are written to device symbols permanently
 *
 */
__device__ __managed__ uint *__memory__;

/**
 * getIndex
 *
 * get the index of the first element for a given node
 *
 * \param src the node for which to get the head index
 * \param rel relation for which to get the head index
 *
 * \return index of the bitvector
 *
 */
__host__ __device__ size_t getIndex(uint src, uint rel)
{
    switch (rel)
    {
    case PTS:
        return OFFSET_PTS + (32 * src);
    case PTS_CURR:
        return OFFSET_PTS_CURR + (32 * src);
    case PTS_NEXT:
        return OFFSET_PTS_NEXT + (32 * src);
    case COPY:
        return OFFSET_COPY + (32 * src);
    case LOAD:
        return OFFSET_LOAD + (32 * src);
    case STORE:
        return OFFSET_STORE + (32 * src);
    }
    // uint index = __memory__[src * N_TYPES + rel];
    return src * 32;
}

__host__ uint incEdgeCouterHost(int type)
{
    uint index = __freeList__[type];
    __freeList__[type] += 32;
    return index;
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
    uint index = getIndex(src, toRel);
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
__host__ void insertEdge(uint src, uint dst, uint *graph, uint toRel)
{
    uint index = getIndex(src, toRel);
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
                uint nextIndex = incEdgeCouterHost(toRel);
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

            uint nextIndex = incEdgeCouterHost(toRel);
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

template <uint fromRel, uint toRel>
__device__ void mergeBitvectors(const uint to, const uint numDstNodes, uint *_shared_);

template <uint fromRel, uint toRel>
__device__ void collectBitvectorTargets(const uint to, const uint bits, const uint base, uint *storage, uint &usedStorage);

__device__ inline uint getAndIncrement(uint *counter, uint delta)
{
    __shared__ volatile uint _shared_[THREADS_PER_BLOCK / WARP_SIZE];
    if (!threadIdx.x)
    {
        _shared_[threadIdx.y] = atomicAdd(counter, delta);
    }
    return _shared_[threadIdx.y];
}

__device__ void insert_store_map(const uint src, uint *const _shared_, uint numFrom)
{
    const uint storeIndex = getIndex(src, STORE);
    for (int i = 0; i < numFrom; i += 32)
    {
        uint size = min(numFrom - i, 32);
        uint next = getAndIncrement(&__storeMapHead__, size);
        // TODO: we need to make sure that (next + threadIdx.x < MAX_HASH_SIZE)
        if (threadIdx.x < size)
        {
            __key__[next + threadIdx.x] = _shared_[i + threadIdx.x]; // at most 2 transactions
            __val__[next + threadIdx.x] = src;
        }
    }
}

__device__ void mergeBitvectorCopy(uint to, uint fromIndex, uint *storage, const uint toRel)
{
    uint toIndex = getIndex(to, toRel);
    if (fromIndex == toIndex)
    {
        return;
    }
    // read dst out edges
    uint fromBits = __memory__[fromIndex + threadIdx.x];
    // get the base from thread nr 30
    uint fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
    // terminate if no data in from bitvector
    if (fromBase == UINT_MAX)
    {
        return;
    }
    // get the next index from thread nr 31
    uint fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);

    // share needed data for to indices
    uint toBits = __memory__[toIndex + threadIdx.x];
    uint toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
    uint toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);

    // keep count of used storage in shared memory
    // this storage is adjacent to previous collectBitvectorTargets memory
    uint numFrom = 0;
    while (1)
    {
        if (toBase == fromBase)
        {
            // union the bits, adding the new edges
            uint orBits = fromBits | toBits;
            uint diffs = __any_sync(0x7FFFFFFF, orBits != toBits);
            bool nextWasUndef = false;
            if (toNext == UINT_MAX && fromNext != UINT_MAX)
            {
                toNext = incEdgeCouter(toRel);
                nextWasUndef = true;
            }
            // each thread gets a value that will be written back to memory
            uint val = threadIdx.x == NEXT ? toNext : orBits;
            if (val != toBits)
                __memory__[toIndex + threadIdx.x] = val;

            // as we are merging into copy,
            // we need to also merge the underlying pts sets
            // we do this by running collectBitvectorTargets
            // and then merge thos pts edges again at the end of this loop
            if (diffs)
            {
                uint diffBits = fromBits & ~toBits;
                collectBitvectorTargets<PTS, PTS_NEXT>(to, diffBits, fromBase, storage, numFrom);
            }
            // if no more bitvectors in origin, end loop
            if (fromNext == UINT_MAX)
            {
                break;
            }
            // else load next bits
            // keep in mind that we do not use insertBitvector
            // since we need to also merge pts edges
            // instead make toBits undefined manually
            // handle this in toBase > fromBase
            toIndex = toNext;
            if (nextWasUndef)
            {
                toBits = UINT_MAX;
                toBase = UINT_MAX;
                toNext = UINT_MAX;
            }
            else
            {
                toBits = __memory__[toIndex + threadIdx.x];
                toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
                toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);
            }
            fromBits = __memory__[fromNext + threadIdx.x];
            fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
            fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
        }
        else if (toBase < fromBase)
        {
            // if toNext is undefined, we need to allocate a new element
            // after that, we can simply insert the origin bitvector
            if (toNext == UINT_MAX)
            {
                uint newNext = incEdgeCouter(toRel);
                __memory__[toIndex + NEXT] = newNext;
                assert(toIndex != newNext);
                toIndex = newNext;
                toBits = UINT_MAX;
                toBase = UINT_MAX;
            }
            else
            {
                toIndex = toNext;
                toBits = __memory__[toNext + threadIdx.x];
                toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
                toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);
            }
        }
        else if (toBase > fromBase)
        {
            // compared to mergeBitvectorPts
            // we need to handle the toBase == UINT_MAX case here
            uint newVal;
            if (toBase == UINT_MAX)
            {
                newVal = fromNext == UINT_MAX ? UINT_MAX : incEdgeCouter(toRel);
            }
            else
            {
                newVal = incEdgeCouter(toRel);
                // write the current bits from the target element to a new location
                __memory__[newVal + threadIdx.x] = toBits;
            }

            // overwrite the current bits with fromBits (insert before node)
            fromBits = threadIdx.x == NEXT ? newVal : fromBits;
            __memory__[toIndex + threadIdx.x] = fromBits;

            // collect pts edges
            collectBitvectorTargets<PTS, PTS_NEXT>(to, fromBits, fromBase, storage, numFrom);

            // if next from element is defined, update the bits
            // if not, break for this element
            if (fromNext == UINT_MAX)
            {
                break;
            }
            toIndex = newVal;

            fromBits = __memory__[fromNext + threadIdx.x];
            fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
            fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
        }
    }
    // merge collected pts edges
    if (numFrom)
    {
        mergeBitvectors<PTS, PTS_NEXT>(to, numFrom, storage);
    }
}

__device__ void insertBitvector(uint toIndex, uint fromBits, uint toRel)
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
        __memory__[toIndex + threadIdx.x] = val;

        // exit if no more elements in from bitvector
        if (fromNext == UINT_MAX)
            return;
        toIndex = toNext;
        fromBits = __memory__[fromNext + threadIdx.x];
    }
}

__device__ void mergeBitvectorPts(uint to, uint fromIndex, const uint toRel)
{
    uint toIndex = getIndex(to, toRel);
    // read dst out edges
    uint fromBits = __memory__[fromIndex + threadIdx.x];
    // get the base from thread nr 30
    uint fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
    // terminate if no data in from bitvector
    if (fromBase == UINT_MAX)
        return;
    // get the next index from thread nr 31
    uint fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);

    // share needed data for to indices
    uint toBits = __memory__[toIndex + threadIdx.x];
    uint toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
    uint toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);

    if (toBase == UINT_MAX)
    {
        insertBitvector(toIndex, fromBits, toRel);
        return;
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
                __memory__[toIndex + threadIdx.x] = val;

            // if no more bitvectors in origin, end loop
            if (fromNext == UINT_MAX)
                return;

            // else load next bits
            fromBits = __memory__[fromNext + threadIdx.x];
            fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
            fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
            if (toNext == UINT_MAX)
            {
                insertBitvector(toIndex, fromBits, toRel);
                return;
            }
            toIndex = newToNext;
            toBits = __memory__[toNext + threadIdx.x];
            toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
            toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);
        }
        else if (toBase < fromBase)
        {
            // if toNext is undefined, we need to allocate a new element
            // after that, we can simply insert the origin bitvector
            if (toNext == UINT_MAX)
            {
                toNext = incEdgeCouter(toRel);
                insertBitvector(toNext, fromBits, toRel);
                return;
            }
            // if toNext is defined, load those to bits for the next iteration
            toIndex = toNext;
            toBits = __memory__[toNext + threadIdx.x];
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
            __memory__[newIndex + threadIdx.x] = toBits;
            // then overwrite the current bits with fromBits (insert before node)
            uint val = threadIdx.x == NEXT ? newIndex : fromBits;
            __memory__[toIndex + threadIdx.x] = val;

            // if next from element is defined, update the bits
            // if not, break for this element
            if (fromNext == UINT_MAX)
                return;

            toIndex = newIndex;

            fromBits = __memory__[fromNext + threadIdx.x];
            fromBase = __shfl_sync(0xFFFFFFFF, fromBits, 30);
            fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
        }
    }
}

template <uint fromRel, uint toRel>
__device__ void mergeBitvectors(const uint to, const uint numDstNodes, uint *_shared_)
{
    // go through all dst nodes, and union the out edges of that node w/ src's out nodes
    for (size_t i = 0; i < numDstNodes; i++)
    {
        uint fromIndex = getIndex(_shared_[i], fromRel);

        if (toRel == COPY)
        {
            mergeBitvectorCopy(to, fromIndex, _shared_ + 128, toRel);
        }
        else
        {
            mergeBitvectorPts(to, fromIndex, toRel);
        }
    }
}

template <uint fromRel, uint toRel>
__device__ void collectBitvectorTargets(const uint to, const uint bits, const uint base, uint *storage, uint &usedStorage)
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
        uint var = getDstNode(base, leastThread, threadIdx.x);
        // check if this thread is looking at a dst node
        // uint bitActive = (var != 1U) && (current_bits & threadMask);
        uint bitActive = (current_bits & threadMask);
        // count threads that are looking at dst nodes
        uint threadsWithDstNode = __ballot_sync(0xFFFFFFFF, bitActive);
        uint numDstNodes = __popc(threadsWithDstNode);
        if (usedStorage + numDstNodes > 128)
        {
            if (toRel == STORE)
                insert_store_map(to, storage, usedStorage);
            else
                mergeBitvectors<fromRel, toRel>(to, usedStorage, storage);
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

__global__ void kernel_store2copy(const uint n)
{
    __shared__ uint _sh_[THREADS_PER_BLOCK / WARP_SIZE * 256];
    uint *const _shared_ = &_sh_[threadIdx.y * 256];
    for (uint i = blockIdx.x * blockDim.y + threadIdx.y; i < n - 1; i += blockDim.y * gridDim.x)
    {
        uint idx = __keyAux__[i];
        uint idx_next = __keyAux__[i + 1];

        // load the pts target, this should not change for the next totalDstNodes
        uint pts_target = __key__[idx];

        for (uint j = idx; j < idx_next; j += 32)
        {
            uint numDstNodes = min(idx_next - j, 32U);
            if (j + threadIdx.x < idx_next)
            {
                _shared_[threadIdx.x] = __val__[j + threadIdx.x];
            }
            mergeBitvectors<STORE, COPY>(pts_target, numDstNodes, _shared_);
        }
    }
}

__global__ void kernel_insert_edges(const uint n, const uint n_unique, uint *from, uint *to, uint *ofst, uint *memory, int rel)
{
    uint index = blockIdx.x * blockDim.y + threadIdx.y;
    uint stride = blockDim.y * gridDim.x;
    uint src, dst, offset, offset_next, j;
    for (int i = index; i < n_unique; i += stride)
    {

        offset = ofst[i];
        offset_next = i == (n_unique - 1) ? n : ofst[i + 1];
        src = from[offset];

        for (j = offset; j < offset_next; j++)
        {
            dst = to[j];
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
    kernel_insert_edges<<<numBlocks, threadsPerBlock>>>(N, numUnique, from, to, ofst, memory, rel);
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
    uint index = getIndex(src, PTS);
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

__host__ uint handleGepEdges(uint *memory, void *consG, void *pag)
{
    edgeSet newPts;
    handleGepsSVF(consG, pag, memory, newPts);
    insertEdges(&newPts, memory, 0, PTS_NEXT);
    uint nodeCount = getNodeCount(consG);
    return nodeCount;
}

__host__ bool aliasBV(uint a, uint b, uint *memory)
{
    std::vector<uint> ptsA, ptsB;

    collectFromBitvector(a, memory, ptsA);
    collectFromBitvector(b, memory, ptsB);

    for (uint target : ptsA)
        if (std::find(ptsB.begin(), ptsB.end(), target) != ptsB.end())
            return true;

    return false;
}

__device__ void cloneAndLink(uint var, const uint ptsIndex, uint &currDiffPtsIndex, const uint diffPtsBits, const uint diffPtsNext)
{
    insertBitvector(ptsIndex, diffPtsBits, PTS);
    if (currDiffPtsIndex != UINT_MAX)
    {
        __memory__[currDiffPtsIndex + NEXT] = ptsIndex;
        assert(currDiffPtsIndex != ptsIndex);
    }
    else
    {
        currDiffPtsIndex = getIndex(var, PTS_CURR);
        uint ptsBits = __memory__[ptsIndex + threadIdx.x];
        __memory__[currDiffPtsIndex + threadIdx.x] = ptsBits;
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
__device__ bool updatePtsAndDiffPts(const uint var)
{
    // next next index
    const uint diffPtsHeadIndex = getIndex(var, PTS_NEXT);

    uint diffPtsBits = __memory__[diffPtsHeadIndex + threadIdx.x];
    uint diffPtsBase = __shfl_sync(0xFFFFFFFF, diffPtsBits, 30);

    if (diffPtsBase == UINT_MAX)
    {
        return false;
    }

    uint diffPtsNext = __shfl_sync(0xFFFFFFFF, diffPtsBits, 31);
    __memory__[diffPtsHeadIndex + threadIdx.x] = UINT_MAX;

    uint ptsIndex = getIndex(var, PTS);
    uint ptsBits = __memory__[ptsIndex + threadIdx.x];
    uint ptsBase = __shfl_sync(0xFFFFFFFF, ptsBits, 30);

    if (ptsBase == UINT_MAX)
    {
        // we pass ptsBase instead of UINT_MAX because it's also UINT_MAX but it can be modified
        cloneAndLink(var, ptsIndex, ptsBase, diffPtsBits, diffPtsNext);
        return true;
    }
    uint ptsNext = __shfl_sync(0xFFFFFFFF, ptsBits, 31);
    uint currDiffPtsIndex = UINT_MAX;
    while (1)
    {
        if (ptsBase > diffPtsBase)
        {
            uint newIndex = incEdgeCouter(PTS);
            __memory__[newIndex + threadIdx.x] = ptsBits;
            uint val = threadIdx.x == NEXT ? newIndex : diffPtsBits;
            __memory__[ptsIndex + threadIdx.x] = val;

            ptsIndex = newIndex;
            // update CURR_DIFF_PTS
            newIndex = currDiffPtsIndex == UINT_MAX ? getIndex(var, PTS_CURR) : incEdgeCouter(PTS_CURR);
            val = threadIdx.x == NEXT ? UINT_MAX : diffPtsBits;
            __memory__[newIndex + threadIdx.x] = val;
            if (currDiffPtsIndex != UINT_MAX)
            {
                __memory__[currDiffPtsIndex + NEXT] = newIndex;
                assert(currDiffPtsIndex != newIndex);
            }
            if (diffPtsNext == UINT_MAX)
            {
                return true;
            }
            currDiffPtsIndex = newIndex;

            diffPtsBits = __memory__[diffPtsNext + threadIdx.x];
            diffPtsBase = __shfl_sync(0xFFFFFFFF, diffPtsBits, 30);
            diffPtsNext = __shfl_sync(0xFFFFFFFF, diffPtsBits, 31);
        }
        else if (ptsBase == diffPtsBase)
        {
            uint newPtsNext = (ptsNext == UINT_MAX && diffPtsNext != UINT_MAX) ? incEdgeCouter(PTS) : ptsNext;
            uint orBits = threadIdx.x == NEXT ? newPtsNext : ptsBits | diffPtsBits;
            uint ballot = __ballot_sync(0xFFFFFFFF, orBits != ptsBits);
            if (ballot)
            {
                __memory__[ptsIndex + threadIdx.x] = orBits;
                if (ballot & ((1 << 30) - 1))
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
                        __memory__[currDiffPtsIndex + NEXT] = newIndex;
                        assert(currDiffPtsIndex != newIndex);
                    }
                    else
                    {
                        newIndex = getIndex(var, PTS_CURR);
                    }
                    __memory__[newIndex + threadIdx.x] = orBits;
                    currDiffPtsIndex = newIndex;
                }
            }
            if (diffPtsNext == UINT_MAX)
            {
                return (currDiffPtsIndex != UINT_MAX);
            }
            diffPtsBits = __memory__[diffPtsNext + threadIdx.x];
            diffPtsBase = __shfl_sync(0xFFFFFFFF, diffPtsBits, 30);
            diffPtsNext = __shfl_sync(0xFFFFFFFF, diffPtsBits, 31);

            if (ptsNext == UINT_MAX)
            {
                cloneAndLink(var, newPtsNext, currDiffPtsIndex, diffPtsBits, diffPtsNext);
                return true;
            }
            ptsIndex = ptsNext;

            ptsBits = __memory__[ptsIndex + threadIdx.x];
            ptsBase = __shfl_sync(0xFFFFFFFF, ptsBits, 30);
            ptsNext = __shfl_sync(0xFFFFFFFF, ptsBits, 31);
        }
        else
        { // ptsBase < diffPtsBase
            if (ptsNext == UINT_MAX)
            {
                uint newPtsIndex = incEdgeCouter(PTS);
                __memory__[ptsIndex + NEXT] = newPtsIndex;
                assert(ptsIndex != newPtsIndex);
                cloneAndLink(var, newPtsIndex, currDiffPtsIndex, diffPtsBits, diffPtsNext);
                return true;
            }
            ptsIndex = ptsNext;
            ptsBits = __memory__[ptsIndex + threadIdx.x];
            ptsBase = __shfl_sync(0xFFFFFFFF, ptsBits, 30);
            ptsNext = __shfl_sync(0xFFFFFFFF, ptsBits, 31);
        }
    }
}

__global__ void kernel_memoryCheck(const uint n)
{
    __syncthreads();

    uint start = blockIdx.x * blockDim.y + threadIdx.y;
    uint stride = blockDim.y * gridDim.x;
    uint bits, base, next, index;

    for (int i = start; i < n; i += stride)
    {
        index = getIndex(i, PTS_CURR);
        while (index != UINT_MAX)
        {
            bits = __memory__[index + threadIdx.x];
            base = __shfl_sync(0xFFFFFFFF, bits, 30);
            if (base == UINT_MAX)
                break;

            next = __shfl_sync(0xFFFFFFFF, bits, 31);
            if (!threadIdx.x && next == index)
            {
                printf("huh?? currpts index: %u has smaller next: %u, freeList: %u\n", index, next, __freeList__[PTS_CURR]);
                break;
            }
            index = next;
        }
    }
    __syncthreads();

    for (int i = start; i < n; i += stride)
    {
        index = getIndex(i, PTS);
        while (index != UINT_MAX)
        {
            bits = __memory__[index + threadIdx.x];
            base = __shfl_sync(0xFFFFFFFF, bits, 30);
            if (base == UINT_MAX)
                break;

            next = __shfl_sync(0xFFFFFFFF, bits, 31);
            if (!threadIdx.x && next == index)
            {
                printf("huh?? pts index: %u has smaller next: %u, freeList: %u\n", index, next, __freeList__[PTS]);
                break;
            }
            index = next;
        }
    }
    __syncthreads();

    for (int i = start; i < n; i += stride)
    {
        index = getIndex(i, PTS_NEXT);
        while (index != UINT_MAX)
        {
            bits = __memory__[index + threadIdx.x];
            base = __shfl_sync(0xFFFFFFFF, bits, 30);
            if (base == UINT_MAX)
                break;

            next = __shfl_sync(0xFFFFFFFF, bits, 31);
            if (!threadIdx.x && next == index)
            {
                printf("huh?? nextpts index: %u has smaller next: %u, freeList: %u\n", index, next, __freeList__[PTS_NEXT]);
                break;
            }
            index = next;
        }
    }
    __syncthreads();
}

__global__ void kernel_count_pts(const uint n, uint rel)
{
    uint start = blockIdx.x * blockDim.y + threadIdx.y;
    uint stride = blockDim.y * gridDim.x;
    uint bits, base, next, index;

    for (int i = start; i < n; i += stride)
    {
        index = getIndex(i, rel);
        while (index != UINT_MAX)
        {
            bits = __memory__[index + threadIdx.x];
            base = __shfl_sync(0xFFFFFFFF, bits, 30);
            if (base == UINT_MAX)
                break;

            uint value = threadIdx.x < BASE ? __popc(bits) : 0;

            for (int i = 16; i >= 1; i /= 2)
                value += __shfl_xor_sync(0x3FFFFFFF, value, i);

            if (!threadIdx.x)
            {
                atomicAdd(&__counter__, value);
            }

            next = __shfl_sync(0xFFFFFFFF, bits, 31);

            index = next;
        }
    }
}

__device__ inline uint resetWorklistIndex()
{
    __syncthreads();
    uint numBlocks = gridDim.x;
    if (!((32 * threadIdx.y) + threadIdx.x) && atomicInc(&__counter__, numBlocks - 1) == (numBlocks - 1))
    {
        __worklistIndex0__ = 0;
        __counter__ = 0;
        return 1;
    }
    return 0;
}

__global__ void kernel_updatePts(const uint n)
{
    __done__ = true;
    bool newWork = false;
    for (uint i = blockIdx.x * blockDim.y + threadIdx.y; i < n; i += blockDim.y * gridDim.x)
    {
        bool newStuff = updatePtsAndDiffPts(i);
        newWork |= newStuff;
        if (!newStuff)
        {
            const uint currPtsHeadIndex = getIndex(i, PTS_CURR);
            __memory__[currPtsHeadIndex + threadIdx.x] = UINT_MAX;
        }
    }
    if (newWork)
    {
        __done__ = false;
    }
    if (resetWorklistIndex())
    {
        __freeList__[PTS_CURR] = n * 32;
        __freeList__[PTS_NEXT] = n * 32;
    }
}

template <uint originRel, uint fromRel, uint toRel>
__device__ void rewriteRule(const uint src, uint *const _shared_)
{
    uint usedShared = 0;
    uint index = getIndex(src, originRel);
    do
    {
        uint bits = __memory__[index + threadIdx.x];
        uint base = __shfl_sync(0xFFFFFFFF, bits, 30);
        if (base == UINT_MAX)
            break;

        collectBitvectorTargets<fromRel, toRel>(src, bits, base, _shared_, usedShared);
        index = __shfl_sync(0xFFFFFFFF, bits, 31);
    } while (index != UINT_MAX);
    if (usedShared)
    {
        if (fromRel == STORE)
            insert_store_map(src, _shared_, usedShared);
        else
            mergeBitvectors<fromRel, toRel>(src, usedShared, _shared_);
    }
}

__global__ void kernel(const uint n, const uint n_stores, uint *storeConstraints)
{
    __shared__ uint _sh_[THREADS_PER_BLOCK / WARP_SIZE * 256];
    uint *const _shared_ = &_sh_[threadIdx.y * 256];
    uint to = n;
    uint src = getAndIncrement(&__worklistIndex1__, 1);
    while (src < to)
    {
        rewriteRule<COPY, PTS_CURR, PTS_NEXT>(src, _shared_ + 128);
        rewriteRule<LOAD, PTS_CURR, COPY>(src, _shared_);

        src = getAndIncrement(&__worklistIndex1__, 1);
    }
    to = n_stores;
    src = getAndIncrement(&__worklistIndex0__, 1);
    while (src < to)
    {
        src = storeConstraints[src];
        if (src != UINT_MAX)
        {
            rewriteRule<PTS_CURR, STORE, STORE>(src, _shared_);
        }
        src = getAndIncrement(&__worklistIndex0__, 1);
    }
    if (resetWorklistIndex())
    {
        __numKeys__ = __storeMapHead__ + 1;
        __storeMapHead__ = 0;
        __worklistIndex1__ = 0;
    }
}

__host__ void printWord(uint *memory, uint src, uint rel, bool isNodeId = true)
{
    // if (isNodeId)
    //     start *= 32;
    uint start;
    if (isNodeId)
        start = getIndex(src, rel);
    else
        start = src;

    for (size_t i = 0; i < 32; i++)
    {
        uint checkpoint = memory[start + i];
        std::cout << checkpoint << "\n";
        std::bitset<sizeof(uint) * 8> x(checkpoint);
        std::cout << x << '\n';
    }
}

__host__ uint *run(unsigned int numNodes, edgeSet *addrEdges, edgeSet *directEdges, edgeSet *loadEdges, edgeSet *storeEdges, void *consG, void *pag)
{
    setlocale(LC_NUMERIC, "");
    // cudaDeviceProp prop; // CUDA device properties variable
    // checkCuda(cudaGetDeviceProperties(&prop, 0));
    // printf("total global memory available:\n\t\t%lu\n", prop.totalGlobalMem);
    // printf("total bytes: \t%lu\n", SIZE_TOTAL_BYTES);
    int N = 1 << 20;
    size_t numStoreDst = storeEdges->second.size();
    uint *store_map_pts, *store_map_src, *store_map_idx, *storeConstraints, *memory;

    // Allocate Unified Memory -- accessible from CPU or GPU
    checkCuda(cudaMallocManaged(&memory, SIZE_TOTAL_BYTES));
    checkCuda(cudaMallocManaged(&store_map_pts, N * sizeof(uint)));
    checkCuda(cudaMallocManaged(&store_map_src, N * sizeof(uint)));
    checkCuda(cudaMallocManaged(&store_map_idx, N * sizeof(uint)));
    checkCuda(cudaMallocManaged(&storeConstraints, numStoreDst * sizeof(uint)));

    // set all values to UINT_MAX
    cudaMemset(memory, UCHAR_MAX, SIZE_TOTAL_BYTES);
    cudaMemset(store_map_pts, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(store_map_src, UCHAR_MAX, N * sizeof(unsigned int));
    cudaMemset(store_map_idx, UCHAR_MAX, N * sizeof(unsigned int));

    // move the store constraints into managed memory and sort / unique
    memcpy(storeConstraints, storeEdges->second.data(), numStoreDst * sizeof(uint));
    thrust::sort(storeConstraints, storeConstraints + numStoreDst);
    size_t numStoreConstraints = thrust::unique(storeConstraints, storeConstraints + numStoreDst) - storeConstraints;

    // num of vertices
    size_t V{numNodes};

    // move managed memory ptrs into device memory
    __memory__ = memory;
    __key__ = store_map_pts;
    __val__ = store_map_src;
    __keyAux__ = store_map_idx;

    // reserve 20% for new edges added by gep offsets
    uint initNum = std::ceil(2 * V) * ELEMENT_WIDTH;
    uint freeList[N_TYPES] = {initNum, initNum, initNum, initNum, initNum, initNum};
    checkCuda(cudaMemcpyToSymbol(__freeList__, freeList, N_TYPES * sizeof(uint)));


    insertEdges(addrEdges, memory, 1, PTS_NEXT);
    insertEdges(directEdges, memory, 1, COPY);
    insertEdges(loadEdges, memory, 1, LOAD);
    insertEdges(storeEdges, memory, 1, STORE);

    dim3 numBlocks(N_BLOCKS);
    dim3 threadsPerBlock(WARP_SIZE, THREADS_PER_BLOCK / WARP_SIZE);

    while (1)
    {
        kernel_updatePts<<<numBlocks, threadsPerBlock>>>(V);
        checkCuda(cudaDeviceSynchronize());


        if (__done__)
        {
            break;
        }

        kernel<<<numBlocks, threadsPerBlock>>>(V, numStoreConstraints, storeConstraints);
        checkCuda(cudaDeviceSynchronize());

        thrust::sort_by_key(thrust::device, store_map_pts, store_map_pts + N, store_map_src);
        auto numSrcs = thrust::unique_by_key_copy(thrust::device, store_map_pts, store_map_pts + N, thrust::make_counting_iterator(0), thrust::make_discard_iterator(), store_map_idx).second - store_map_idx;

        kernel_store2copy<<<numBlocks, threadsPerBlock>>>(numSrcs);
        checkCuda(cudaDeviceSynchronize());
        uint Vnew = handleGepEdges(memory, consG, pag);
        V = Vnew;
    }
    // Free memory
    checkCuda(cudaFree(store_map_pts));
    checkCuda(cudaFree(store_map_src));
    checkCuda(cudaFree(store_map_idx));

    return memory;
}