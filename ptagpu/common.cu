#include "common.cuh"

/**
 * relNames
 *
 * this variable holds strings for each of the relations
 * this allows us to get a name from a numeric relation
 *
 */
char const *relNames[6] = {"PTS", "PTS Current", "PTS Next", "Inv COPY", "Inv LOAD", "Inv Store"};

struct KernelInfo
{
    bool initialized = false;
    dim3 blockSize;
    dim3 gridSize;
    size_t sharedMemory;
    float elapsedTime = 0;
    cudaEvent_t start, stop;
};

typedef void (*kernel_function)();

std::map<kernel_function, KernelInfo> kernelParameters;

__device__ __managed__ size_t V;

/**
 * __ptsFreeList__
 * this is the head of the free list
 * keeps track of last allocated memory location
 * access needs to be atomic to prevent collisions
 *
 */
__device__ __managed__ uint __freeList__[N_TYPES];
__device__ __managed__ uint tmpFreePtsCurr = 0;
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
__device__ __managed__ uint *__offsets__;

__device__ __managed__ uint __numKeys__;

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

__device__ __managed__ uint *__storeConstraints__;
__device__ __managed__ uint __numStoreConstraints__;

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

__device__ inline uint incEdgeCouter(int type)
{
    uint newIndex;
    if (!threadIdx.x)
        newIndex = atomicAdd(&__freeList__[type], 32);
    newIndex = __shfl_sync(0xFFFFFFFF, newIndex, 0);
    return newIndex;
}

__device__ uint insertEdgeDevice(uint src, uint dst, uint toRel)
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
        uint toBits = __memory__[index + threadIdx.x];
        uint toBase = __shfl_sync(0xFFFFFFFF, toBits, 30);
        if (toBase == UINT_MAX)
        {
            __memory__[index + threadIdx.x] = myBits;
            return index;
        }
        if (toBase == base)
        {
            uint orBits = toBits | myBits;
            if (orBits != toBits && threadIdx.x < NEXT)
                __memory__[index + threadIdx.x] = orBits;

            return index;
        }
        if (toBase < base)
        {
            uint toNext = __shfl_sync(0xFFFFFFFF, toBits, 31);
            if (toNext == UINT_MAX)
            {
                uint newIndex = incEdgeCouter(toRel);
                __memory__[index + NEXT] = newIndex;
                __memory__[newIndex + threadIdx.x] = myBits;
                return newIndex;
            }
            index = toNext;
        }
        else
        {
            uint newIndex = incEdgeCouter(toRel);
            __memory__[newIndex + threadIdx.x] = toBits;
            uint val = threadIdx.x == NEXT ? newIndex : myBits;
            __memory__[index + threadIdx.x] = val;
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
    uint newIndex;
    if (!threadIdx.x)
        newIndex = atomicAdd(counter, delta);
    newIndex = __shfl_sync(0xFFFFFFFF, newIndex, 0);
    return newIndex;
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

__device__ inline uint resetWorklistIndex()
{
    __syncthreads();
    uint numBlocks = gridDim.x;
    if (!threadIdx.x && !threadIdx.y && atomicInc(&__counter__, numBlocks - 1) == (numBlocks - 1))
    {
        __worklistIndex0__ = 0;
        __counter__ = 0;
        return 1;
    }
    return 0;
}

__device__ void mergeBitvectorCopy(const uint to, const uint fromIndex, uint *const storage, bool applyCopy = true)
{
    uint toIndex = getIndex(to, COPY);
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
    uint newVal;
    while (1)
    {

        if (toBase == fromBase)
        {
            // union the bits, adding the new edges
            uint orBits = fromBits | toBits;
            uint diffs = __any_sync(0xFFFFFFFF, orBits != toBits && threadIdx.x < NEXT);
            bool nextWasUINT_MAX = false;
            if (toNext == UINT_MAX && fromNext != UINT_MAX)
            {
                toNext = incEdgeCouter(COPY);
                nextWasUINT_MAX = true;
            }

            // each thread gets a value that will be written back to memory
            uint val = threadIdx.x == NEXT ? toNext : orBits;
            if (val != toBits)
                __memory__[toIndex + threadIdx.x] = val;

            // as we are merging into copy,
            // we need to also merge the underlying pts sets
            // we do this by running collectBitvectorTargets
            // and then merge thos pts edges again at the end of this loop
            if (applyCopy && diffs)
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
            if (nextWasUINT_MAX)
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
                uint newNext = incEdgeCouter(COPY);
                __memory__[toIndex + NEXT] = newNext;
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
            if (toBase == UINT_MAX)
            {
                newVal = fromNext == UINT_MAX ? UINT_MAX : incEdgeCouter(COPY);
            }
            else
            {
                newVal = incEdgeCouter(COPY);
                // write the current bits from the target element to a new location
                __memory__[newVal + threadIdx.x] = toBits;
            }

            // overwrite the current bits with fromBits (insert before node)
            fromBits = threadIdx.x == NEXT ? newVal : fromBits;
            __memory__[toIndex + threadIdx.x] = fromBits;
            if (applyCopy)
            {
                // collect pts edges for resolving the copy edges later
                collectBitvectorTargets<PTS, PTS_NEXT>(to, fromBits, fromBase, storage, numFrom);
            }

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
    if (applyCopy && numFrom)
    {
        mergeBitvectors<PTS, PTS_NEXT>(to, numFrom, storage);
    }
}

__device__ void insertBitvector(uint toIndex, uint fromBits, uint fromNext, const uint toRel)
{
    while (1)
    {
        // check if a new bitvector is required
        // if that is the case, allocate a new index for a new element
        uint newIndex = fromNext == UINT_MAX ? UINT_MAX : incEdgeCouter(toRel);
        // handle the special next entry, since we can not reuse the fromNext bits
        uint val = threadIdx.x == NEXT ? newIndex : fromBits;
        // write new values to target memory location
        __memory__[toIndex + threadIdx.x] = val;

        // exit if no more elements in from bitvector
        if (fromNext == UINT_MAX)
            break;

        // start next iteration
        toIndex = newIndex;
        fromBits = __memory__[fromNext + threadIdx.x];
        // use warp intrinsics to get next index in from memory
        fromNext = __shfl_sync(0xFFFFFFFF, fromBits, 31);
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
        insertBitvector(toIndex, fromBits, fromNext, toRel);
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
                insertBitvector(toIndex, fromBits, fromNext, toRel);
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
                __memory__[toIndex + NEXT] = toNext;
                insertBitvector(toNext, fromBits, fromNext, toRel);
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
            mergeBitvectorCopy(to, fromIndex, _shared_ + 128);
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
    uint nonEmptyThreads = __ballot_sync(0xFFFFFFFF, bits) & 0x3FFFFFFF;
    const uint threadMask = 1 << threadIdx.x;
    const uint myMask = threadMask - 1;
    while (nonEmptyThreads)
    {
        // work through the nonEmptyThreads bits, get thread number of first thread w/ non empty bits
        int leastThread = __ffs(nonEmptyThreads) - 1;
        // remove lsb from nonEmptyThreads (iteration step)
        nonEmptyThreads &= (nonEmptyThreads - 1);
        // share current bits with all threads in warp
        uint current_bits = __shfl_sync(0xFFFFFFFF, bits, leastThread);

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

__global__ void kernel_store2copy()
{
    extern __shared__ uint _sh_[];
    uint *const _shared_ = &_sh_[threadIdx.y * 256];
    for (uint i = blockIdx.x * blockDim.y + threadIdx.y; i < __numKeys__ - 1; i += blockDim.y * gridDim.x)
    {
        uint idx = __offsets__[i];
        uint idx_next = __offsets__[i + 1];

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

__global__ void kernel_insert_edges(uint rel)
{
    uint index = blockIdx.x * blockDim.y + threadIdx.y;
    uint stride = blockDim.y * gridDim.x;
    uint src, dst, offset, offset_next, j;
    for (int i = index; i < __numKeys__ - 1; i += stride)
    {

        offset = __offsets__[i];
        offset_next = __offsets__[i + 1];
        src = __key__[offset];

        for (j = offset; j < offset_next; j++)
        {
            dst = __val__[j];
            insertEdgeDevice(src, dst, rel);
        }
    }
}

__host__ void kernelWrapper(void *kernel, const char *statusString, void **args = 0)
{
    printf("%s", statusString);
    KernelInfo *config = &kernelParameters[kernel];

    if (!config->initialized)
    {
        cudaEventCreate(&config->start);
        cudaEventCreate(&config->stop);
        int optimalBlockSize;
        int optimalGridSize;

        size_t dynamicSMemUsage = 32 * 256 * sizeof(uint);

        checkCuda(cudaOccupancyMaxPotentialBlockSize(&optimalGridSize, &optimalBlockSize, kernel, dynamicSMemUsage, 0));

        printf("[automatic kernel configuration] calculated blkSize: %i and grdSize: %i for kernel [%p]\n", optimalBlockSize, optimalGridSize, kernel);

        dim3 gridSize(optimalGridSize);
        dim3 blockSize(WARP_SIZE, optimalBlockSize / WARP_SIZE);

        config->gridSize = gridSize;
        config->blockSize = blockSize;
        config->initialized = true;
        config->sharedMemory = dynamicSMemUsage;
    }
    checkCuda(cudaDeviceSynchronize());
    checkCuda(cudaEventRecord(config->start, 0));
    checkCuda(cudaLaunchKernel(kernel, config->gridSize, config->blockSize, args, config->sharedMemory, 0));
    checkCuda(cudaEventRecord(config->stop, 0));
    checkCuda(cudaEventSynchronize(config->stop));
    float elapsedTime;
    checkCuda(cudaEventElapsedTime(&elapsedTime, config->start, config->stop));
    config->elapsedTime += elapsedTime;
}

__host__ void insertEdges(edgeSet *edges, int inv, int rel)
{
    uint numEdges = edges->second.size();
    uint N = numEdges + 1;

    assert(N <= KV_SIZE);

    if (inv)
    {
        memcpy(__key__, edges->second.data(), numEdges * sizeof(unsigned int));
        memcpy(__val__, edges->first.data(), numEdges * sizeof(unsigned int));
    }
    else
    {
        memcpy(__key__, edges->first.data(), numEdges * sizeof(unsigned int));
        memcpy(__val__, edges->second.data(), numEdges * sizeof(unsigned int));
    }

    __key__[numEdges] = UINT_MAX;
    __val__[numEdges] = UINT_MAX;

    auto kv_start = thrust::make_zip_iterator(thrust::make_tuple(__key__, __val__));
    thrust::sort(thrust::device, kv_start, kv_start + N);
    __numKeys__ = thrust::unique_by_key_copy(thrust::device, __key__, __key__ + N, thrust::make_counting_iterator(0), thrust::make_discard_iterator(), __offsets__).second - __offsets__;

    void *kernelArgs[] = {
        (void *)&rel,
    };

    kernelWrapper((void *)&kernel_insert_edges, "", kernelArgs);
}

/**
 * collect pts targets for src
 */
__host__ void collectFromBitvector(uint src, uint *memory, std::vector<uint> &pts, uint rel)
{
    uint index = getIndex(src, rel);
    while (index != UINT_MAX)
    {
        uint base = memory[index + 30U];
        uint next = memory[index + 31U];
        if (base == UINT_MAX)
        {
            break;
        }
        for (size_t j = 0; j < 30U; j++)
        {
            uint value = memory[index + j];
            for (size_t k = 0; k < 32; k++)
            {
                if (value & 1)
                {
                    pts.push_back(base * 960 + j * 32 + k);
                }
                value >>= 1;
            }
        }
        index = next;
    }
}

__host__ bool aliasBV(uint a, uint b, uint *memory)
{
    std::vector<uint> ptsA, ptsB;

    collectFromBitvector(a, memory, ptsA, PTS);
    collectFromBitvector(b, memory, ptsB, PTS);

    for (uint target : ptsA)
        if (std::find(ptsB.begin(), ptsB.end(), target) != ptsB.end())
            return true;

    return false;
}

__device__ void insertBitvectorAndLink(uint var, const uint ptsIndex, uint &currDiffPtsIndex, const uint diffPtsBits, const uint diffPtsNext)
{
    insertBitvector(ptsIndex, diffPtsBits, diffPtsNext, PTS);
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
__device__ bool computeDiffPts(const uint var)
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
        insertBitvectorAndLink(var, ptsIndex, ptsBase, diffPtsBits, diffPtsNext);
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
                insertBitvectorAndLink(var, newPtsNext, currDiffPtsIndex, diffPtsBits, diffPtsNext);
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
                insertBitvectorAndLink(var, newPtsIndex, currDiffPtsIndex, diffPtsBits, diffPtsNext);
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

__global__ void kernel_updatePts()
{
    __done__ = true;
    bool newWork = false;
    for (uint i = blockIdx.x * blockDim.y + threadIdx.y; i < V; i += blockDim.y * gridDim.x)
    {
        bool newStuff = computeDiffPts(i);
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
        tmpFreePtsCurr = __freeList__[PTS_CURR];
        __freeList__[PTS_CURR] = OFFSET_PTS_CURR + __reservedHeader__;
        __freeList__[PTS_NEXT] = OFFSET_PTS_NEXT + __reservedHeader__;
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

__global__ void kernel()
{
    extern __shared__ uint _sh_[];
    uint *const _shared_ = &_sh_[threadIdx.y * 256];
    uint to = V;
    uint src = getAndIncrement(&__worklistIndex1__, 1);
    while (src < to)
    {
        rewriteRule<COPY, PTS_CURR, PTS_NEXT>(src, _shared_ + 128);
        rewriteRule<LOAD, PTS_CURR, COPY>(src, _shared_);

        src = getAndIncrement(&__worklistIndex1__, 1);
    }
    to = __numStoreConstraints__;
    src = getAndIncrement(&__worklistIndex0__, 1);
    while (src < to)
    {
        src = __storeConstraints__[src];
        if (src != UINT_MAX)
        {
            rewriteRule<PTS_CURR, STORE, STORE>(src, _shared_);
        }
        src = getAndIncrement(&__worklistIndex0__, 1);
    }
    if (resetWorklistIndex())
    {
        __key__[__storeMapHead__] = UINT_MAX;
        __val__[__storeMapHead__] = UINT_MAX;
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

__host__ void printAllPts(uint V, uint *memory, uint rel)
{
    for (size_t i = 0; i < V; i++)
    {
        uint index = getIndex(i, rel);
        printf("\n %lu -> [", i);
        while (index != UINT_MAX)
        {
            uint base = __memory__[index + BASE];
            uint next = __memory__[index + NEXT];
            if (base == UINT_MAX)
            {
                break;
            }
            for (size_t j = 0; j < BASE; j++)
            {
                uint value = __memory__[index + j];
                for (size_t k = 0; k < 32; k++)
                {
                    if (value & 1)
                    {
                        printf("%u ", getDstNode(base, j, k));
                    }
                    value >>= 1;
                }
            }
            index = next;
        }
        printf("]");
    }
}

__host__ void printAllPtsMinimal(uint V, uint *memory, uint rel)
{
    for (size_t i = 0; i < V; i++)
    {
        std::vector<uint> targets;
        collectFromBitvector(i, memory, targets, rel);
        if (targets.size())
        {
            printf("\n %lu -> [", i);
            for (auto t : targets)
                printf("%u ", t);
            printf("]");
        }
    }
}

__host__ void printMemory(uint start, uint end, uint rel)
{
    uint usedUints;
    if (rel == PTS_CURR)
        usedUints = tmpFreePtsCurr - start;
    else
        usedUints = __freeList__[rel] - start;
    size_t usedBytes = usedUints * sizeof(uint);
    size_t totalBytes = (end - start) * sizeof(uint);
    assert(usedBytes < totalBytes);
    printf("%12s Elements:(uints)%16u\t[%10.3f MiB / %5lu MiB]\n", relNames[rel], usedUints, (usedBytes / (1024.0 * 1024.0)), totalBytes >> 20);
}

__host__ void reportMemory()
{
    printf("##### MEMORY USAGE\n");
    printMemory(OFFSET_PTS, TOTAL_MEMORY_LENGTH, PTS);
    printMemory(OFFSET_PTS_CURR, OFFSET_PTS, PTS_CURR);
    printMemory(OFFSET_PTS_NEXT, OFFSET_PTS_CURR, PTS_NEXT);
    printMemory(OFFSET_COPY, OFFSET_PTS_NEXT, COPY);
    printMemory(OFFSET_LOAD, OFFSET_COPY, LOAD);
    printMemory(OFFSET_STORE, OFFSET_LOAD, STORE);
    printf("##### MEMORY USAGE\n");
}

__host__ uint *run(unsigned int numNodes, edgeSet *addrEdges, edgeSet *directEdges, edgeSet *loadEdges, edgeSet *storeEdges, void *consG, void *pag, std::function<uint(uint *, edgeSet *pts, edgeSet *copy)> callgraphCallback)
{
    setlocale(LC_NUMERIC, "");
    // cudaDeviceProp prop; // CUDA device properties variable
    // checkCuda(cudaGetDeviceProperties(&prop, 0));
    // printf("total global memory available:\n\t\t%lu\n", prop.totalGlobalMem);
    // printf("total bytes: \t%lu\n", SIZE_TOTAL_BYTES);
    size_t numStoreDst = storeEdges->second.size();
    uint *memory;
    // Allocate Unified Memory -- accessible from CPU or GPU
    checkCuda(cudaMallocManaged(&memory, SIZE_TOTAL_BYTES));
    // checkCuda(cudaHostAlloc(&memory, SIZE_TOTAL_BYTES, cudaHostAllocMapped | 0));
    checkCuda(cudaMallocManaged(&__key__, KV_SIZE * sizeof(uint)));
    checkCuda(cudaMallocManaged(&__val__, KV_SIZE * sizeof(uint)));
    checkCuda(cudaMallocManaged(&__offsets__, KV_SIZE * sizeof(uint)));
    checkCuda(cudaMallocManaged(&__storeConstraints__, numStoreDst * sizeof(uint)));

    // set all values to UINT_MAX
    cudaMemset(memory, UCHAR_MAX, SIZE_TOTAL_BYTES);
    cudaMemset(__key__, UCHAR_MAX, KV_SIZE * sizeof(unsigned int));
    cudaMemset(__val__, UCHAR_MAX, KV_SIZE * sizeof(unsigned int));
    cudaMemset(__offsets__, UCHAR_MAX, KV_SIZE * sizeof(unsigned int));

    // move the store constraints into managed memory and sort / unique
    memcpy(__storeConstraints__, storeEdges->second.data(), numStoreDst * sizeof(uint));
    thrust::sort(__storeConstraints__, __storeConstraints__ + numStoreDst);
    __numStoreConstraints__ = thrust::unique(__storeConstraints__, __storeConstraints__ + numStoreDst) - __storeConstraints__;

    // num of vertices
    V = numNodes;
    size_t V_max = (size_t)ceil(1.2 * V);

    // move managed memory ptrs into device memory
    __memory__ = memory;
    // checkCuda(cudaHostGetDevicePointer(&__memory__, memory, 0));

    // reserve 20% for new edges added by gep offsets
    __reservedHeader__ = V_max * ELEMENT_WIDTH;
    __freeList__[PTS] = OFFSET_PTS + __reservedHeader__;
    __freeList__[PTS_CURR] = OFFSET_PTS_CURR + __reservedHeader__;
    __freeList__[PTS_NEXT] = OFFSET_PTS_NEXT + __reservedHeader__;
    __freeList__[COPY] = OFFSET_COPY + __reservedHeader__;
    __freeList__[LOAD] = OFFSET_LOAD + __reservedHeader__;
    __freeList__[STORE] = OFFSET_STORE + __reservedHeader__;

    insertEdges(addrEdges, 1, PTS_NEXT);
    insertEdges(directEdges, 1, COPY);
    insertEdges(loadEdges, 1, LOAD);
    insertEdges(storeEdges, 1, STORE);

    dim3 numBlocks(N_BLOCKS);
    dim3 threadsPerBlock(WARP_SIZE, THREADS_PER_BLOCK / WARP_SIZE);

    cudaStreamCreate(&mainStream);

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

        thrust::zip_iterator<thrust::tuple<uint *, uint *>> kv_start = thrust::make_zip_iterator(thrust::make_tuple(store_map_pts, store_map_src));
        thrust::sort(thrust::device, kv_start, kv_start + __numKeys__);
        auto numSrcs = thrust::unique_by_key_copy(thrust::device, store_map_pts, store_map_pts + __numKeys__, thrust::make_counting_iterator(0), thrust::make_discard_iterator(), store_map_idx).second - store_map_idx;

        kernel_store2copy<<<numBlocks, threadsPerBlock>>>(numSrcs);
        checkCuda(cudaDeviceSynchronize());

        edgeSet newPts, newCopys;
        uint Vnew = callgraphCallback(memory, &newPts, &newCopys);
        insertEdges(&newPts, 0, PTS_NEXT);
        insertEdges(&newCopys, 1, COPY);
        V = Vnew;
    }
    // Free memory
    checkCuda(cudaFree(store_map_pts));
    checkCuda(cudaFree(store_map_src));
    checkCuda(cudaFree(store_map_idx));

    return memory;
}