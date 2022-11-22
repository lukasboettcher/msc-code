#include "common.cuh"

/**
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

/**
 *
 * store calculated kernel parameters here
 *
 */
std::map<void *, KernelInfo> kernelParameters;

/**
 * represents the number of nodes in the graph
 *
 */
__device__ __managed__ size_t V;

/**
 * keeps track of last allocated memory location
 * for each memory region / relation
 * access needs to be atomic to prevent collisions
 *
 */
__device__ __managed__ index_t __freeList__[N_TYPES];

/**
 * is a temporary counter for statistics,
 * since freelist for currpts is reset after updatePts
 *
 */
__device__ __managed__ index_t tmpFreePtsCurr = 0;

/**
 *
 * this variable represents to max number of nodes
 *
 * is to be initialized with enough overhead
 * to allow adding further nodes via gep offsets calculations
 * currently set to 120% of constraint graph
 *
 */
__device__ __managed__ uint __reservedHeader__;

/**
 *
 * flag that keeps track of remaining work
 * if true, no next iteration needed
 *
 */
__device__ __managed__ bool __done__ = true;

/**
 *
 * these variables are used throughout the
 * code for hashmap operations
 * where keys are associated w/ values
 * and then sorted / uniqued
 *
 */
__device__ __managed__ uint *__key__;

/**
 *
 * these variables are used throughout the
 * code for hashmap operations
 * where keys are associated w/ values
 * and then sorted / uniqued
 *
 */
__device__ __managed__ uint *__val__;

/**
 *
 * these variables are used throughout the
 * code for hashmap operations
 * where keys are associated w/ values
 * and then sorted / uniqued
 *
 */
__device__ __managed__ uint *__offsets__;

/**
 * __numKeys__
 *
 * as kv pair memory is allocated once
 * with overhead, __numKeys__ keeps track
 * of actually used space to prevent
 * redundant work
 *
 */
__device__ __managed__ uint __numKeys__;

/**
 *
 * various counters for wortklist algorithms
 * adapted from mendez et. al
 *
 */
__device__ __managed__ uint __counter__ = 0;

/**
 *
 * various counters for wortklist algorithms
 * adapted from mendez et. al
 *
 */
__device__ uint __worklistIndex0__ = 0;

/**
 *
 * various counters for wortklist algorithms
 * adapted from mendez et. al
 *
 */
__device__ uint __worklistIndex1__ = 0;

/**
 *
 * is used as a freelist for the kv store
 *
 */
__device__ uint __storeMapHead__ = 0;

/**
 *
 * device pointers for the pts bitvectors
 * these need to be accesses adhoc
 * so are written to device symbols permanently
 *
 */
__device__ __managed__ uint *__memory__;

/**
 *
 * alternative memory location
 * for store constraints
 * separate from main memory
 * for store inv kernel
 *
 */
__device__ __managed__ uint *__storeConstraints__;

/**
 *
 * is the corresponding counter
 *
 */
__device__ __managed__ uint __numStoreConstraints__;

/**
 *
 * get the index of the first element for a given node
 *
 * \param src the node for which to get the head index
 * \param rel relation for which to get the head index
 *
 * \return index of the bitvector
 *
 */
__host__ __device__ index_t getIndex(uint src, uint rel)
{
    switch (rel)
    {
    case PTS:
        return OFFSET_PTS + (ELEMENT_WIDTH * src);
    case PTS_CURR:
        return OFFSET_PTS_CURR + (ELEMENT_WIDTH * src);
    case PTS_NEXT:
        return OFFSET_PTS_NEXT + (ELEMENT_WIDTH * src);
    case COPY:
        return OFFSET_COPY + (ELEMENT_WIDTH * src);
    case LOAD:
        return OFFSET_LOAD + (ELEMENT_WIDTH * src);
    case STORE:
        return OFFSET_STORE + (ELEMENT_WIDTH * src);
    }
    return src * ELEMENT_WIDTH;
}

/**
 *
 * increment the edge counter and return free memory location
 * for new element from the host
 *
 * \param type relation for which to reserve memory
 *
 * \return index for new bitvector elememt
 *
 */
__host__ index_t incEdgeCouterHost(int type)
{
    index_t index = __freeList__[type];
    __freeList__[type] += 32;
    return index;
}

/**
 *
 * increment the edge counter and return free memory location
 * for new element from the device
 *
 * \param type relation for which to reserve memory
 *
 * \return index for new bitvector elememt
 *
 */
__device__ inline index_t incEdgeCouter(int type)
{
    index_t newIndex;
    if (!threadIdx.x)
        newIndex = atomicAdd_system(&__freeList__[type], 32);
    newIndex = __shfl_sync(FULL_MASK, newIndex, 0);
    return newIndex;
}

/**
 *
 * insert an edge into the right memory location from device
 *
 * \param src edge src
 * \param dst edge dst
 * \param toRel edge type
 *
 * \return index for inserted edge
 *
 */
__device__ index_t insertEdgeDevice(uint src, uint dst, uint toRel)
{
    index_t index = getIndex(src, toRel);
    uint base = BASE_OF(dst);
    uint word = WORD_OF(dst);
    uint bit = BIT_OF(dst);
    uint myBits = 0;

    if (threadIdx.x == word)
        myBits = 1 << bit;
    else if (threadIdx.x == BASE)
        myBits = base;
    else if (threadIdx.x == NEXT_LOWER)
        myBits = UINT_MAX;
    else if (threadIdx.x == NEXT_UPPER)
        myBits = UINT_MAX;

    while (1)
    {
        uint toBits = __memory__[index + threadIdx.x];
        uint toBase = __shfl_sync(FULL_MASK, toBits, BASE);
        if (toBase == UINT_MAX)
        {
            __memory__[index + threadIdx.x] = myBits;
            return index;
        }
        else if (toBase == base)
        {
            uint orBits = toBits | myBits;
            if (orBits != toBits && threadIdx.x < NEXT_LOWER)
                __memory__[index + threadIdx.x] = orBits;

            return index;
        }
        else if (toBase < base)
        {
            index_t toNext = thread_load_size_t(toBits);
            if (toNext == ULLONG_MAX)
            {
                index_t newIndex = incEdgeCouter(toRel);
                store_size_t(__memory__, index, newIndex);
                __memory__[newIndex + threadIdx.x] = myBits;
                return newIndex;
            }
            index = toNext;
        }
        else if (toBase > base)
        {
            index_t newIndex = incEdgeCouter(toRel);
            __memory__[newIndex + threadIdx.x] = toBits;
            uint val = thread_load_val(myBits, newIndex);
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
    index_t index = getIndex(src, toRel);
    uint base = BASE_OF(dst);
    uint word = WORD_OF(dst);
    uint bit = BIT_OF(dst);

    if (graph[index + BASE] == UINT_MAX)
    {
        for (size_t i = 0; i < BASE; i++)
            graph[index + i] = 0;
        graph[index + BASE] = base;
        graph[index + word] |= 1 << bit;
        return;
    }

    while (1)
    {
        uint toBase = graph[index + BASE];
        index_t toNext = load_size_t(graph[index + NEXT_LOWER], graph[index + NEXT_UPPER]);

        if (toBase == UINT_MAX)
        {
            for (size_t i = 0; i < BASE; i++)
                graph[index + i] = 0;
            graph[index + BASE] = base;
            graph[index + word] |= 1 << bit;
            return;
        }
        if (toBase < base)
        {
            if (toNext == ULLONG_MAX)
            {
                index_t nextIndex = incEdgeCouterHost(toRel);
                store_size_t(graph, index, nextIndex);

                for (size_t i = 0; i < BASE; i++)
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

            index_t nextIndex = incEdgeCouterHost(toRel);
            for (size_t i = 0; i < ELEMENT_WIDTH; i++)
                graph[nextIndex + i] = graph[index + i];
            for (size_t i = 0; i < BASE; i++)
                graph[nextIndex + i] = 0;
            graph[index + BASE] = base;
            store_size_t(graph, index, nextIndex);
            graph[index + word] |= 1 << bit;
        }
    }
}

template <uint fromRel, uint toRel>
__device__ void mergeBitvectors(const uint to, const uint numDstNodes, uint *_shared_);

template <uint fromRel, uint toRel>
__device__ void collectBitvectorTargets(const uint to, const uint bits, const uint base, uint *storage, uint &usedStorage);

/**
 *
 * helper function to increment counter
 * used in worklist algorithms
 * syncd via warp intrinsics
 *
 * \param counter counter to be incremented
 * \param delta amount to increment
 *
 * \return previous counter value
 *
 */
__device__ inline uint getAndIncrement(uint *counter, uint delta)
{
    uint cnt;
    if (!threadIdx.x)
        cnt = atomicAdd_system(counter, delta);
    cnt = __shfl_sync(FULL_MASK, cnt, 0);
    return cnt;
}

/**
 *
 * helper function to reset worklist counters
 * after operation
 * syncs blocks and grid by using counter
 *
 *
 * \return boolean whether thread is grid leader
 *
 */
__device__ inline uint resetWorklistIndex()
{
    __syncthreads();
    if (!threadIdx.x && !threadIdx.y && atomicInc_system(&__counter__, gridDim.x - 1) == (gridDim.x - 1))
    {
        __worklistIndex0__ = 0;
        __counter__ = 0;
        return 1;
    }
    return 0;
}

/**
 *
 * insert store, pointer pair into kv store
 *
 * \param src corresponding store src node
 * \param _shared_ passed shared memory containing nodes
 * \param numFrom numver of values in shared memory
 *
 * \return previous counter value
 *
 */
__device__ void insert_store_map(const uint src, uint *const _shared_, uint numFrom)
{
    const index_t storeIndex = getIndex(src, STORE);
    for (int i = 0; i < numFrom; i += 32)
    {
        uint size = min(numFrom - i, 32);
        uint next = getAndIncrement(&__storeMapHead__, size);
        if (threadIdx.x < size)
        {
            __key__[next + threadIdx.x] = _shared_[i + threadIdx.x];
            __val__[next + threadIdx.x] = src;
        }
    }
}

/**
 *
 * merges two bitvectors and optionally applies copy
 * pointer operations
 *
 * \param to target node
 * \param fromIndex index of second rel nodes, to be merged
 * \param storage shared memory shard for recursive mergeBV call
 * \param applyCopy should always be true, apply copy rule?
 *
 */
__device__ void mergeBitvectorCopy(const uint to, const index_t fromIndex, uint *const storage, bool applyCopy = true)
{
    index_t toIndex = getIndex(to, COPY);
    if (fromIndex == toIndex)
    {
        return;
    }
    // read dst out edges
    uint fromBits = __memory__[fromIndex + threadIdx.x];
    // get the base from thread
    uint fromBase = __shfl_sync(FULL_MASK, fromBits, BASE);
    // terminate if no data in from bitvector
    if (fromBase == UINT_MAX)
    {
        return;
    }
    // get the next index from thread
    index_t fromNext = thread_load_size_t(fromBits);

    // share needed data for to indices
    uint toBits = __memory__[toIndex + threadIdx.x];
    uint toBase = __shfl_sync(FULL_MASK, toBits, BASE);
    index_t toNext = thread_load_size_t(toBits);

    // keep count of used storage in shared memory
    // this storage is adjacent to previous collectBitvectorTargets memory
    uint numFrom = 0;
    index_t newVal;
    while (1)
    {

        if (toBase == fromBase)
        {
            // union the bits, adding the new edges
            uint orBits = fromBits | toBits;
            uint diffs = __any_sync(FULL_MASK, orBits != toBits && threadIdx.x < NEXT_LOWER);
            bool nextWasUINT_MAX = false;
            if (toNext == ULLONG_MAX && fromNext != ULLONG_MAX)
            {
                toNext = incEdgeCouter(COPY);
                nextWasUINT_MAX = true;
            }

            // each thread gets a value that will be written back to memory
            uint val = thread_load_val(orBits, toNext);
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
            if (fromNext == ULLONG_MAX)
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
                toNext = ULLONG_MAX;
            }
            else
            {
                toBits = __memory__[toIndex + threadIdx.x];
                toBase = __shfl_sync(FULL_MASK, toBits, BASE);
                toNext = thread_load_size_t(toBits);
            }

            fromBits = __memory__[fromNext + threadIdx.x];
            fromBase = __shfl_sync(FULL_MASK, fromBits, BASE);
            fromNext = __shfl_sync(FULL_MASK, fromBits, NEXT_LOWER);
            fromNext = thread_load_size_t(fromBits);
        }
        else if (toBase < fromBase)
        {
            // if toNext is undefined, we need to allocate a new element
            // after that, we can simply insert the origin bitvector
            if (toNext == ULLONG_MAX)
            {
                index_t newNext = incEdgeCouter(COPY);
                store_size_t(__memory__, toIndex, newNext);
                toIndex = newNext;
                toBits = UINT_MAX;
                toBase = UINT_MAX;
            }
            else
            {
                toIndex = toNext;

                toBits = __memory__[toNext + threadIdx.x];
                toBase = __shfl_sync(FULL_MASK, toBits, BASE);
                toNext = thread_load_size_t(toBits);
            }
        }
        else if (toBase > fromBase)
        {
            // compared to mergeBitvectorPts
            // we need to handle the toBase == UINT_MAX case here
            if (toBase == ULLONG_MAX)
            {
                newVal = fromNext == ULLONG_MAX ? ULLONG_MAX : incEdgeCouter(COPY);
            }
            else
            {
                newVal = incEdgeCouter(COPY);
                // write the current bits from the target element to a new location
                __memory__[newVal + threadIdx.x] = toBits;
            }

            // overwrite the current bits with fromBits (insert before node)
            fromBits = thread_load_val(fromBits, newVal);
            __memory__[toIndex + threadIdx.x] = fromBits;
            if (applyCopy)
            {
                // collect pts edges for resolving the copy edges later
                collectBitvectorTargets<PTS, PTS_NEXT>(to, fromBits, fromBase, storage, numFrom);
            }

            // if next from element is defined, update the bits
            // if not, break for this element
            if (fromNext == ULLONG_MAX)
            {
                break;
            }

            toIndex = newVal;

            fromBits = __memory__[fromNext + threadIdx.x];
            fromBase = __shfl_sync(FULL_MASK, fromBits, BASE);
            fromNext = thread_load_size_t(fromBits);
        }
    }

    // merge collected pts edges
    if (applyCopy && numFrom)
    {
        mergeBitvectors<PTS, PTS_NEXT>(to, numFrom, storage);
    }
}

/**
 *
 * if to BV is empty, just write from BV w/o merging
 * simply assign new elements for next elements
 *
 * \param toIndex target node
 * \param fromBits bits to be written
 * \param fromNext next from index, passed so it does not have to be recomputed
 * \param toRel target relation
 *
 */
__device__ void insertBitvector(index_t toIndex, uint fromBits, index_t fromNext, const uint toRel)
{
    while (1)
    {
        // check if a new bitvector is required
        // if that is the case, allocate a new index for a new element
        index_t newIndex = fromNext == ULLONG_MAX ? ULLONG_MAX : incEdgeCouter(toRel);
        // handle the special next entry, since we can not reuse the fromNext bits
        uint val = thread_load_val(fromBits, newIndex);
        // write new values to target memory location
        __memory__[toIndex + threadIdx.x] = val;

        // exit if no more elements in from bitvector
        if (fromNext == ULLONG_MAX)
            break;

        // start next iteration
        toIndex = newIndex;
        fromBits = __memory__[fromNext + threadIdx.x];
        // use warp intrinsics to get next index in from memory
        fromNext = thread_load_size_t(fromBits);
    }
}

/**
 *
 * merges two bitvectors w/o copy targets,
 * so no recursive calls
 *
 * \param to target node
 * \param fromIndex index of second rel node
 * \param toRel target relation, used for new element allocations
 *
 */
__device__ void mergeBitvectorPts(uint to, index_t fromIndex, const uint toRel)
{
    index_t toIndex = getIndex(to, toRel);
    // read dst out edges
    uint fromBits = __memory__[fromIndex + threadIdx.x];
    // get the base from thread
    uint fromBase = __shfl_sync(FULL_MASK, fromBits, BASE);
    // terminate if no data in from bitvector
    if (fromBase == UINT_MAX)
        return;
    // get the next index from thread
    index_t fromNext = thread_load_size_t(fromBits);

    // share needed data for to indices
    uint toBits = __memory__[toIndex + threadIdx.x];
    uint toBase = __shfl_sync(FULL_MASK, toBits, BASE);
    index_t toNext = thread_load_size_t(toBits);

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
            index_t newToNext = (toNext == ULLONG_MAX && fromNext != ULLONG_MAX) ? incEdgeCouter(toRel) : toNext;
            // union the bits, adding the new edges
            uint orBits = fromBits | toBits;
            // each thread gets a value that will be written back to memory
            uint val = thread_load_val(orBits, newToNext);
            if (val != toBits)
                __memory__[toIndex + threadIdx.x] = val;

            // if no more bitvectors in origin, end loop
            if (fromNext == ULLONG_MAX)
                return;

            // else load next bits
            fromBits = __memory__[fromNext + threadIdx.x];
            fromBase = __shfl_sync(FULL_MASK, fromBits, BASE);
            fromNext = thread_load_size_t(fromBits);
            if (toNext == ULLONG_MAX)
            {
                insertBitvector(newToNext, fromBits, fromNext, toRel);
                return;
            }
            toIndex = newToNext;
            toBits = __memory__[toNext + threadIdx.x];
            toBase = __shfl_sync(FULL_MASK, toBits, BASE);
            toNext = thread_load_size_t(toBits);
        }
        else if (toBase < fromBase)
        {
            // if toNext is undefined, we need to allocate a new element
            // after that, we can simply insert the origin bitvector
            if (toNext == ULLONG_MAX)
            {
                toNext = incEdgeCouter(toRel);
                store_size_t(__memory__, toIndex, toNext);
                insertBitvector(toNext, fromBits, fromNext, toRel);
                return;
            }
            // if toNext is defined, load those to bits for the next iteration
            toIndex = toNext;
            toBits = __memory__[toNext + threadIdx.x];
            toBase = __shfl_sync(FULL_MASK, toBits, BASE);
            toNext = thread_load_size_t(toBits);
        }
        else if (toBase > fromBase)
        {
            // if toBase is greater than frombase
            // we need to insert another bitvector element before toindex
            // and shift the current element back (ref. linked lists)
            index_t newIndex = incEdgeCouter(toRel);
            // write the current bits from the target element to a new location
            __memory__[newIndex + threadIdx.x] = toBits;
            // then overwrite the current bits with fromBits (insert before node)
            uint val = thread_load_val(fromBits, newIndex);
            __memory__[toIndex + threadIdx.x] = val;

            // if next from element is defined, update the bits
            // if not, break for this element
            if (fromNext == ULLONG_MAX)
                return;

            toIndex = newIndex;

            fromBits = __memory__[fromNext + threadIdx.x];
            fromBase = __shfl_sync(FULL_MASK, fromBits, BASE);
            fromNext = thread_load_size_t(fromBits);
        }
    }
}

/**
 *
 * general mergeBitvector function
 * calls mergeBitvectorPts or mergeBitvectorCopy
 * depending on template relations
 *
 * \param to target node
 * \param numDstNodes size of shared memory
 * \param _shared_ shared memory shard containing second rel nodes
 *
 */
template <uint fromRel, uint toRel>
__device__ void mergeBitvectors(const uint to, const uint numDstNodes, uint *_shared_)
{
    // go through all dst nodes, and union the out edges of that node w/ src's out nodes
    for (size_t i = 0; i < numDstNodes; i++)
    {
        index_t fromIndex = getIndex(_shared_[i], fromRel);

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

/**
 *
 * read bits and read bitvector uints to calculate
 * and collect target nodes in shared memory
 *
 * \param to target node
 * \param bits bits to be read
 * \param base base of element to be read
 * \param storage shared memory to be used for collection
 * \param usedStorage used to keep track of nodes stored in shared memory
 *
 */
template <uint fromRel, uint toRel>
__device__ void collectBitvectorTargets(const uint to, const uint bits, const uint base, uint *storage, uint &usedStorage)
{
    // create mask for threads w/ dst nodes, except last
    uint nonEmptyThreads = __ballot_sync(FULL_MASK, bits) & BV_THREADS_MASK;
    const uint threadMask = 1 << threadIdx.x;
    const uint myMask = threadMask - 1;
    while (nonEmptyThreads)
    {
        // work through the nonEmptyThreads bits, get thread number of first thread w/ non empty bits
        int leastThread = __ffs(nonEmptyThreads) - 1;
        // remove lsb from nonEmptyThreads (iteration step)
        nonEmptyThreads &= (nonEmptyThreads - 1);
        // share current bits with all threads in warp
        uint current_bits = __shfl_sync(FULL_MASK, bits, leastThread);

        // use the base and the word of the current thread's bits to calculate the target dst id
        uint var = getDstNode(base, leastThread, threadIdx.x);
        // check if this thread is looking at a dst node
        // uint bitActive = (var != 1U) && (current_bits & threadMask);
        uint bitActive = (current_bits & threadMask);
        // count threads that are looking at dst nodes
        uint threadsWithDstNode = __ballot_sync(FULL_MASK, bitActive);
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

/**
 *
 * use the kv store w/ store and pts pairs
 * to add all copy edges resulting from store -> pts paths
 *
 */
__global__ void
__launch_bounds__(THREADS_PER_BLOCK)
    kernel_store2copy()
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

/**
 *
 * kernel_insert_edges to add all edges in kv store to graph
 *
 * \param rel since all edges are coalesced by type we need to know the edge relation
 *
 */
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

/**
 *
 * kernelWrapper to automatically determine optimal parameters for the kernel
 * as well as synchronizing needed events
 *
 * \param kernel the kernel to be executed
 * \param statusString string to be printed before execution of the kernel
 * \param args **args holds the kernel parameters
 *
 */
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

/**
 *
 * host method to write edges into the memory
 * stored edges in kv store on gpu to efficiently
 * insert edges
 *
 * \param edges an edgeSet containing all the edges as two vectors
 * \param inv bool whether or not the edges are inverted or not
 * \param rel target relation for the edges
 *
 */
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

    dim3 numBlocks(N_BLOCKS);
    dim3 threadsPerBlock(WARP_SIZE, THREADS_PER_BLOCK / WARP_SIZE);
    checkCuda(cudaDeviceSynchronize());
    kernel_insert_edges<<<numBlocks, threadsPerBlock, 0>>>(rel);
    checkCuda(cudaDeviceSynchronize());
}

/**
 *
 * collect pts targets for src in memory
 * this is used from the host
 *
 * \param src nodeid to collect targets for
 * \param memory memory to probe for targets
 * \param pts vector where to add the collected nodes (reference)
 * \param rel relation to probe in memory
 *
 */
__host__ void collectFromBitvector(uint src, uint *memory, std::vector<uint> &pts, uint rel)
{
    index_t index = getIndex(src, rel);
    while (index != ULLONG_MAX)
    {
        uint base = memory[index + BASE];
        index_t next = load_size_t(memory[index + NEXT_LOWER], memory[index + NEXT_UPPER]);
        if (base == UINT_MAX)
        {
            break;
        }
        for (size_t j = 0; j < BASE; j++)
        {
            uint value = memory[index + j];
            for (size_t k = 0; k < 32; k++)
            {
                if (value & 1)
                {
                    pts.push_back(base * ELEMENT_CARDINALITY + j * 32 + k);
                }
                value >>= 1;
            }
        }
        index = next;
    }
}

/**
 *
 * check of two nodes alias, based on gpu (managed) memory
 *
 * \param a node 1
 * \param a node 2
 * \param memory memory to probe for targets
 *
 * \return bool for alias relation
 *
 */
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

/**
 *
 * same as insertBitvector, but link instead of copying
 * used when updating pts.
 * reuse pts memory for currpts
 *
 * \param var currently updating this node
 * \param ptsIndex index in the pts, dest for data
 * \param currDiffPtsIndex index in currpts, 2nd dest for data, next to nextpts index
 * \param diffPtsBits nextpts bits, source of data
 * \param diffPtsNext nextpts next, rest of source data
 *
 */
__device__ void insertBitvectorAndLink(uint var, const index_t ptsIndex, index_t &currDiffPtsIndex, const uint diffPtsBits, const index_t diffPtsNext)
{
    insertBitvector(ptsIndex, diffPtsBits, diffPtsNext, PTS);
    if (currDiffPtsIndex != ULLONG_MAX)
    {
        store_size_t(__memory__, currDiffPtsIndex, ptsIndex);
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
 * PTS_CURR as the difference between the old and new PTS for the given variable.
 *
 * @param var nodeid for currently updating variable
 * @return true if new pts edges have been added to this variable
 */
__device__ bool computeDiffPts(const uint var)
{
    // get diffpts index
    const index_t diffPtsIndex = getIndex(var, PTS_NEXT);

    // read diffpts data
    uint diffPtsBits = __memory__[diffPtsIndex + threadIdx.x];
    uint diffPtsBase = __shfl_sync(FULL_MASK, diffPtsBits, BASE);

    if (diffPtsBase == UINT_MAX)
    {
        return false;
    }
    // get next element for diffpts
    index_t diffPtsNext = thread_load_size_t(diffPtsBits);
    // reset the diffpts data
    __memory__[diffPtsIndex + threadIdx.x] = UINT_MAX;

    // get pts index
    index_t ptsIndex = getIndex(var, PTS);

    // get pts data
    uint ptsBits = __memory__[ptsIndex + threadIdx.x];
    uint ptsBase = __shfl_sync(FULL_MASK, ptsBits, BASE);

    if (ptsBase == UINT_MAX)
    {
        // use dummy variable for currDiffPtsIndex and insert
        index_t tmp = ULLONG_MAX;
        insertBitvectorAndLink(var, ptsIndex, tmp, diffPtsBits, diffPtsNext);
        return true;
    }
    // get next pts element
    index_t ptsNext = thread_load_size_t(ptsBits);

    // init currDiffPtsIndex to undef
    index_t currDiffPtsIndex = ULLONG_MAX;
    while (1)
    {
        if (ptsBase > diffPtsBase)
        {
            // insert new element for diffpts data
            // and write previous pts data to new element
            index_t newIndex = incEdgeCouter(PTS);
            __memory__[newIndex + threadIdx.x] = ptsBits;
            uint val = thread_load_val(diffPtsBits, newIndex);
            __memory__[ptsIndex + threadIdx.x] = val;

            // update pts index
            ptsIndex = newIndex;

            // also write to currpts, instead of only writing to pts
            newIndex = currDiffPtsIndex == ULLONG_MAX ? getIndex(var, PTS_CURR) : incEdgeCouter(PTS_CURR);
            val = threadIdx.x < NEXT_LOWER ? diffPtsBits : UINT_MAX;
            __memory__[newIndex + threadIdx.x] = val;
            if (currDiffPtsIndex != ULLONG_MAX)
                store_size_t(__memory__, currDiffPtsIndex, newIndex);

            // abort if diffpts next is undefined alse update index
            if (diffPtsNext == ULLONG_MAX)
                return true;
            currDiffPtsIndex = newIndex;

            // get next diffpts data
            diffPtsBits = __memory__[diffPtsNext + threadIdx.x];
            diffPtsBase = __shfl_sync(FULL_MASK, diffPtsBits, BASE);
            diffPtsNext = thread_load_size_t(diffPtsBits);
        }
        else if (ptsBase == diffPtsBase)
        {
            // calculate bits that should be merged w/ pts
            index_t newPtsNext = (ptsNext == ULLONG_MAX && diffPtsNext != ULLONG_MAX) ? incEdgeCouter(PTS) : ptsNext;
            uint orBits = thread_load_val(ptsBits | diffPtsBits, newPtsNext);
            uint ballot = __ballot_sync(FULL_MASK, orBits != ptsBits);
            if (ballot)
            {
                // write the orbits
                __memory__[ptsIndex + threadIdx.x] = orBits;
                if (ballot & ((1 << BASE) - 1))
                {
                    orBits = diffPtsBits & ~ptsBits;
                    if (threadIdx.x == BASE)
                    {
                        orBits = ptsBase;
                    }
                    else if (threadIdx.x == NEXT_LOWER)
                    {
                        orBits = UINT_MAX;
                    }
                    else if (threadIdx.x == NEXT_UPPER)
                    {
                        orBits = UINT_MAX;
                    }

                    // now write diffPtsBits & ~ptsBits to currpts at correct index
                    index_t newIndex;
                    if (currDiffPtsIndex != ULLONG_MAX)
                    {

                        newIndex = incEdgeCouter(PTS_CURR);
                        store_size_t(__memory__, currDiffPtsIndex, newIndex);
                    }
                    else
                    {
                        newIndex = getIndex(var, PTS_CURR);
                    }
                    __memory__[newIndex + threadIdx.x] = orBits;
                    currDiffPtsIndex = newIndex;
                }
            }

            // abort of diffnext in undefined
            if (diffPtsNext == ULLONG_MAX)
            {
                return (currDiffPtsIndex != ULLONG_MAX);
            }

            // else get next diff data
            diffPtsBits = __memory__[diffPtsNext + threadIdx.x];
            diffPtsBase = __shfl_sync(FULL_MASK, diffPtsBits, BASE);
            diffPtsNext = thread_load_size_t(diffPtsBits);

            // if pts next is undefined skip next iteration and insertBitvectorAndLink instead
            if (ptsNext == ULLONG_MAX)
            {
                insertBitvectorAndLink(var, newPtsNext, currDiffPtsIndex, diffPtsBits, diffPtsNext);
                return true;
            }

            // else iterate and get next pts data as well
            ptsIndex = ptsNext;

            ptsBits = __memory__[ptsIndex + threadIdx.x];
            ptsBase = __shfl_sync(FULL_MASK, ptsBits, BASE);
            ptsNext = thread_load_size_t(ptsBits);
        }
        else if (ptsBase < diffPtsBase)
        {
            // when ptsBase is too small and has no next, insertBitvectorAndLink
            if (ptsNext == ULLONG_MAX)
            {
                index_t newPtsIndex = incEdgeCouter(PTS);
                store_size_t(__memory__, ptsIndex, newPtsIndex);
                insertBitvectorAndLink(var, newPtsIndex, currDiffPtsIndex, diffPtsBits, diffPtsNext);
                return true;
            }

            // else get next pts data and iterate
            ptsIndex = ptsNext;
            ptsBits = __memory__[ptsIndex + threadIdx.x];
            ptsBase = __shfl_sync(FULL_MASK, ptsBits, BASE);
            ptsNext = thread_load_size_t(ptsBits);
        }
    }
}

/**
 * debug function to do some sanity checks on the memory
 * i.e. check if index == next, which would result in infinite loops
 *
 */
__global__ void kernel_memoryCheck()
{
    __syncthreads();

    uint start = blockIdx.x * blockDim.y + threadIdx.y;
    uint stride = blockDim.y * gridDim.x;
    uint bits, base;
    index_t next, index;

    for (int i = start; i < V; i += stride)
    {
        index = getIndex(i, PTS_CURR);
        while (index != ULLONG_MAX)
        {
            bits = __memory__[index + threadIdx.x];
            base = __shfl_sync(FULL_MASK, bits, BASE);
            if (base == UINT_MAX)
                break;

            next = __shfl_sync(FULL_MASK, bits, NEXT_LOWER);
            if (!threadIdx.x && next == index)
            {
                printf("currpts index: %llu has smaller next: %llu, freeList: %llu\n", index, next, __freeList__[PTS_CURR]);
                break;
            }
            index = next;
        }
    }
    __syncthreads();

    for (int i = start; i < V; i += stride)
    {
        index = getIndex(i, PTS);
        while (index != ULLONG_MAX)
        {
            bits = __memory__[index + threadIdx.x];
            base = __shfl_sync(FULL_MASK, bits, BASE);
            if (base == UINT_MAX)
                break;

            next = __shfl_sync(FULL_MASK, bits, NEXT_LOWER);
            if (!threadIdx.x && next == index)
            {
                printf("pts index: %llu has smaller next: %llu, freeList: %llu\n", index, next, __freeList__[PTS]);
                break;
            }
            index = next;
        }
    }
    __syncthreads();

    for (int i = start; i < V; i += stride)
    {
        index = getIndex(i, PTS_NEXT);
        while (index != ULLONG_MAX)
        {
            bits = __memory__[index + threadIdx.x];
            base = __shfl_sync(FULL_MASK, bits, BASE);
            if (base == UINT_MAX)
                break;

            next = __shfl_sync(FULL_MASK, bits, NEXT_LOWER);
            if (!threadIdx.x && next == index)
            {
                printf("nextpts index: %llu has smaller next: %llu, freeList: %llu\n", index, next, __freeList__[PTS_NEXT]);
                break;
            }
            index = next;
        }
    }
    __syncthreads();
}

/**
 *
 * count targets in type of bitvector
 * does not have to be pts, can be any memory region containing bitvectors
 *
 * \param rel for which to count the targets
 *
 */
__global__ void kernel_count_pts(uint rel)
{
    uint start = blockIdx.x * blockDim.y + threadIdx.y;
    uint stride = blockDim.y * gridDim.x;
    uint bits, base;
    index_t next, index;

    for (int i = start; i < V; i += stride)
    {
        index = getIndex(i, rel);
        while (index != ULLONG_MAX)
        {
            bits = __memory__[index + threadIdx.x];
            base = __shfl_sync(FULL_MASK, bits, BASE);
            if (base == UINT_MAX)
                break;

            uint value = threadIdx.x < BASE ? __popc(bits) : 0;

#if __CUDA_ARCH__ >= 800 && 0
            __reduce_add_sync(FULL_MASK, value);
#else
            for (int i = 16; i >= 1; i /= 2)
                value += __shfl_xor_sync(FULL_MASK, value, i);
#endif

            if (!threadIdx.x)
                atomicAdd(&__counter__, value);

            next = thread_load_size_t(bits);

            index = next;
        }
    }
}

/**
 *
 * update the pointer memory regions
 * PTS = PTS U PTS_NEXT
 * PTS_CURR = PTS_NEXT \ PTS
 *
 */
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
            const index_t currPtsHeadIndex = getIndex(i, PTS_CURR);
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

/**
 *
 * general rewrite rule
 * given two relations, insert new edges for a third relation connecting both
 * X -a-> Y -b-> Z  => X -c-> Z
 *
 * \param src apply rewrite rule for this variable
 * \param _shared_ block of allocated shared memory
 *
 */
template <uint originRel, uint fromRel, uint toRel>
__device__ void rewriteRule(const uint src, uint *const _shared_)
{
    uint usedShared = 0;
    index_t index = getIndex(src, originRel);
    do
    {
        uint bits = __memory__[index + threadIdx.x];
        uint base = __shfl_sync(FULL_MASK, bits, BASE);
        if (base == UINT_MAX)
            break;
        index = thread_load_size_t(bits);
        collectBitvectorTargets<fromRel, toRel>(src, bits, base, _shared_, usedShared);
    } while (index != ULLONG_MAX);
    if (usedShared)
    {
        if (fromRel == STORE)
            insert_store_map(src, _shared_, usedShared);
        else
            mergeBitvectors<fromRel, toRel>(src, usedShared, _shared_);
    }
}

/**
 *
 * this is the main kernel
 * which applies copy load and partly store rewrite rules
 *
 */
__global__ void
__launch_bounds__(THREADS_PER_BLOCK)
    kernel()
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

/**
 *
 * helper function to print a bitvector element in its binary representation
 * very useful for debugging
 *
 * \param memory graph to print from
 * \param src nodeid / memory location to read
 * \param rel target relation to read from memory
 * \param isNodeId whether to calculate index from src or use as is, first is the default behaviour
 *
 */
__host__ void printWord(uint *memory, index_t src, uint rel, bool isNodeId = true)
{
    index_t start;
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
    std::cout << '\n';
}

/**
 *
 * helper function to print all pts for a relation in a graph
 *
 * \param V number of nodes in graph
 * \param memory graph to print from
 * \param rel target relation to read from memory
 *
 */
__host__ void printAllPts(uint V, uint *memory, uint rel)
{
    for (size_t i = 0; i < V; i++)
    {
        uint index = getIndex(i, rel);
        printf("\n %lu -> [", i);
        while (index != UINT_MAX)
        {
            uint base = __memory__[index + BASE];
            uint next = __memory__[index + NEXT_LOWER];
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

/**
 *
 * helper function to print all pts minimally for a relation in a graph
 * minimal means that empty sets are omitted for easier reading / parsing
 *
 * \param V number of nodes in graph
 * \param memory graph to print from
 * \param rel target relation to read from memory
 *
 */
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

/**
 *
 * print the memory state for a single relation in memory
 * use freelist ot get state
 *
 * \param start start offset of the memory region (rel)
 * \param end end offset of the memory region (rel)
 * \param rel target relation to read from freelist
 *
 */
__host__ void printMemory(index_t start, index_t end, uint rel)
{
    index_t usedUints;
    if (rel == PTS_CURR)
        usedUints = tmpFreePtsCurr - start;
    else
        usedUints = __freeList__[rel] - start;
    size_t usedBytes = usedUints * sizeof(uint);
    size_t totalBytes = (end - start) * sizeof(uint);
    assert(usedBytes < totalBytes);
    printf("%12s Elements:(uints)%16llu\t[%10.3f MiB / %5lu MiB]\n", relNames[rel], usedUints, (usedBytes / (1024.0 * 1024.0)), totalBytes >> 20);
}

/**
 *
 * helper function to print the current state of memory
 * print used and available memory for all relations in a graph
 *
 */
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

/**
 *
 * mainloop to calculate transitive closure for a given andersen analysis problem
 * \return pointer for final memory, containing all relations
 *
 */
__host__ uint *run(unsigned int numNodes, edgeSet *addrEdges, edgeSet *directEdges, edgeSet *loadEdges, edgeSet *storeEdges, std::function<uint(uint *, edgeSet *pts, edgeSet *copy)> callgraphCallback)
{
    setlocale(LC_NUMERIC, "");

    int N_GPU;
    checkCuda(cudaGetDeviceCount(&N_GPU));
    cudaStream_t streams[N_GPU];

    for (int i = 0; i < N_GPU; i++)
    {
        checkCuda(cudaSetDevice(i));
        checkCuda(cudaFree(0));
        checkCuda(cudaStreamCreate(&streams[i]));
    }
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

    size_t iter = 0;

    std::chrono::high_resolution_clock::time_point before, after;
    std::chrono::duration<double, std::milli> timeThrust(0), timeSvf(0), timeUpdate(0), timeKernel(0), timeStore(0);

    while (1)
    {
        ++iter;
        printf("updating info \n");
        checkCuda(cudaDeviceSynchronize());
        before = std::chrono::high_resolution_clock::now();
        kernel_updatePts<<<numBlocks, threadsPerBlock, 0>>>();
        checkCuda(cudaDeviceSynchronize());
        after = std::chrono::high_resolution_clock::now();
        timeUpdate += std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(after - before);

        checkCuda(cudaDeviceSynchronize());
        kernel_count_pts<<<numBlocks, threadsPerBlock, 0>>>(PTS_CURR);
        checkCuda(cudaDeviceSynchronize());
        printf("\tnum currpts after update: %'u\n", __counter__);
        __counter__ = 0;

        if (__done__)
        {
            std::cout << "\t\tno change recorded, aborting main loop in iter: " << iter << "\n";
            break;
        }

        edgeSet newPts, newCopys;
        std::future<uint> cbFuture = std::async(callgraphCallback, memory, &newPts, &newCopys);

        printf("\trunning main kernel\n");
        checkCuda(cudaDeviceSynchronize());
        before = std::chrono::high_resolution_clock::now();

        for (int i = 0; i < N_GPU; i++)
        {
            cudaSetDevice(i);
            kernel<<<numBlocks, threadsPerBlock, 256 * sizeof(uint) * threadsPerBlock.y, streams[i]>>>();
        }
        for (int i = 0; i < N_GPU; i++)
        {
            cudaSetDevice(i);
            cudaStreamSynchronize(streams[i]);
        }
        cudaSetDevice(0);

        // kernel<<<numBlocks, threadsPerBlock, 256 * sizeof(uint) * threadsPerBlock.y>>>();
        // checkCuda(cudaDeviceSynchronize());
        after = std::chrono::high_resolution_clock::now();
        timeKernel += std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(after - before);

        before = std::chrono::high_resolution_clock::now();
        std::cout << "\tsorting and calculating offsets for store kernel\n";
        auto sync_exec_policy = thrust::device;
        thrust::zip_iterator<thrust::tuple<uint *, uint *>> kv_start = thrust::make_zip_iterator(thrust::make_tuple(__key__, __val__));
        thrust::sort(sync_exec_policy, kv_start, kv_start + __numKeys__);
        __numKeys__ = thrust::unique_by_key_copy(sync_exec_policy, __key__, __key__ + __numKeys__, thrust::make_counting_iterator(0), thrust::make_discard_iterator(), __offsets__).second - __offsets__;
        after = std::chrono::high_resolution_clock::now();
        timeThrust += std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(after - before);

        checkCuda(cudaDeviceSynchronize());
        before = std::chrono::high_resolution_clock::now();
        kernel_store2copy<<<numBlocks, threadsPerBlock, 256 * sizeof(uint) * threadsPerBlock.y>>>();
        checkCuda(cudaDeviceSynchronize());
        after = std::chrono::high_resolution_clock::now();
        timeStore += std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(after - before);

        std::cout << "\thandle gep edges & ind calls";
        before = std::chrono::high_resolution_clock::now();
        uint Vnew = cbFuture.get();
        printf("  inserting %lu  ", newPts.first.size());
        insertEdges(&newPts, 0, PTS_NEXT);
        insertEdges(&newCopys, 1, COPY);
        printf("  inserting done  ");
        std::cout << "\tnew nodes: " << Vnew - V << " new V: " << Vnew << "\n";
        after = std::chrono::high_resolution_clock::now();
        timeSvf += std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(after - before);
        V = Vnew;
        reportMemory();
    }

    printf("time update: %.3f ms\n", timeUpdate.count());
    printf("time kernel: %.3f ms\n", timeKernel.count());
    printf("time thrust: %.3f ms\n", timeThrust.count());
    printf("time store : %.3f ms\n", timeStore.count());
    printf("time svf   : %.3f ms\n", timeSvf.count());

    // Free memory
    checkCuda(cudaFree(__key__));
    checkCuda(cudaFree(__val__));
    checkCuda(cudaFree(__offsets__));
    checkCuda(cudaFree(__storeConstraints__));

    return memory;
}