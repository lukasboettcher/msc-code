#include <pthread.h>
#include <stdio.h>
#include <assert.h>
#include <math.h>
#include <time.h>
#define checkCuda(val) check((val), #val, __FILE__, __LINE__)
void check(cudaError_t err, const char *const func, const char *const file, const int line)
{
    if (err != cudaSuccess)
    {
        fprintf(stderr, "CUDA Runtime Error at: '%s:%i'\n\t%s %s\n", file, line, cudaGetErrorString(err), func);
        exit(EXIT_FAILURE);
    }
}

int args[100];
// const size_t N = 1 * 1024 * 1024 * 1024L;
const size_t N = 2 * 1024 * 1024 * 1024L;
int num_gpus;

__device__ __managed__ uint *__memory__;
__managed__ uint N_FIB = 10000;

__device__ __host__ uint fib(uint n)
{
    uint a = 0, b = 1, c, i;
    if (n == 0)
        return a;
    for (i = 2; i <= n; i++)
    {
        c = a + b;
        a = b;
        b = c;
    }
    return b;
}

__global__ void kernel(size_t start, size_t end)
{
    uint tid = start + threadIdx.x + blockIdx.x * blockDim.x;
    for (uint i = tid; i < end; i += blockDim.x * gridDim.x)
    {
        __memory__[i] = i + fib(N_FIB);
    }
}

void *launch_kernel(void *arg)
{
    int threadId = *((int *)arg);

    cudaSetDevice(threadId);

    size_t perGpu = (N + num_gpus - 1) / num_gpus;

    size_t start = threadId * perGpu;
    size_t end = min(N, start + perGpu);

    cudaMemAdvise(__memory__ + start, perGpu, cudaMemAdviseSetPreferredLocation, threadId);
    cudaMemPrefetchAsync(__memory__ + start, perGpu, threadId, cudaStreamPerThread);

    printf("\tstarting thread %i w/ start: %lu end: %lu | total: %lu, pergpu: %lu\n", threadId, start, end, N, perGpu);

    kernel<<<80, 1024>>>(start, end);

    cudaStreamSynchronize(cudaStreamPerThread);

    return NULL;
}

void verify()
{
    uint static_fib = fib(N_FIB);
    for (size_t i = 0; i < N; i++)
        // assert(__memory__[i] == i);
        if (__memory__[i] != i + static_fib)
        {
            fprintf(stderr, "error, w/ iter: %lu\n", i);
            break;
        }
}

void run_multi_kernel()
{
    cudaMemset(__memory__, UCHAR_MAX, sizeof(uint) * N);
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    const int num_threads = num_gpus;

    pthread_t threads[num_threads];

    cudaEventRecord(start, 0);

    for (int i = 0; i < num_threads; i++)
    {
        args[i] = i;
        if (pthread_create(&threads[i], NULL, launch_kernel, &args[i]))
        {
            fprintf(stderr, "Error creating threadn");
        }
    }

    for (int i = 0; i < num_threads; i++)
    {
        if (pthread_join(threads[i], NULL))
        {
            fprintf(stderr, "Error joining threadn");
        }
    }

    cudaDeviceSynchronize();
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);

    printf("multi device (pthreads) done after: %.3fms \n", elapsedTime);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    verify();
}

void run_single_kernel()
{
    cudaMemset(__memory__, UCHAR_MAX, sizeof(uint) * N);
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaMemset(__memory__, UCHAR_MAX, sizeof(uint) * N);
    cudaEventRecord(start, 0);
    kernel<<<80, 1024>>>(0, N);
    cudaDeviceSynchronize();
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);

    printf("single device done after: %.3fms \n", elapsedTime);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    verify();
}

void run_multi_kernel_new()
{
    checkCuda(cudaMemset(__memory__, UCHAR_MAX, sizeof(uint) * N));
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaStream_t streams[num_gpus];

    for (int i = 0; i < num_gpus; i++)
    {
        printf("\tcudaMemAdvise and prefetch for device %i\n", i);
        size_t perGpu = (N + num_gpus - 1) / num_gpus;
        size_t start = i * perGpu;
        size_t end = min(N, start + perGpu);
        cudaSetDevice(i);
        cudaStreamCreate(&streams[i]);
        cudaMemAdvise(__memory__ + start, (end - start) * sizeof(uint), cudaMemAdviseSetPreferredLocation, i);
        cudaMemPrefetchAsync(__memory__ + start, (end - start) * sizeof(uint), i, streams[i]);
    }

    cudaEventRecord(start, 0);

    for (int i = 0; i < num_gpus; i++)
    {
        size_t perGpu = (N + num_gpus - 1) / num_gpus;
        size_t start = i * perGpu;
        size_t end = min(N, start + perGpu);
        checkCuda(cudaSetDevice(i));
        checkCuda(cudaStreamCreate(&streams[i]));
        printf("\tstarting device %i on data [%lu, %lu) total: %lu\n", i, start, end, N);
        kernel<<<80, 1024, 0, streams[i]>>>(start, end);
    }

    for (int i = 0; i < num_gpus; i++)
    {
        cudaStreamSynchronize(streams[i]);
    }

    cudaSetDevice(0);
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);

    printf("multi device (new) done after: %.3fms \n", elapsedTime);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    verify();
}

int main()
{
    cudaGetDeviceCount(&num_gpus);

    cudaMallocManaged(&__memory__, sizeof(uint) * N);

    run_multi_kernel();

    run_single_kernel();

    run_multi_kernel_new();

    cudaFree(__memory__);

    cudaError_t result;
    result = cudaGetLastError();
    if (cudaSuccess != result)
    {
        fprintf(stderr, "error during execution: %s\n", cudaGetErrorString(result));
    }

    return 0;
}