
__global__ void kernel(size_t *A, size_t N)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i < N)
        A[i] = i;
}
#include <assert.h>
#include <stdio.h>
#define checkCuda(val) check((val), #val, __FILE__, __LINE__)
void check(cudaError_t err, const char *const func, const char *const file, const int line)
{
    if (err != cudaSuccess)
    {
        fprintf(stderr, "CUDA Runtime Error at: '%s:%i'\n\t%s %s\n", file, line, cudaGetErrorString(err), func);
        exit(EXIT_FAILURE);
    }
}

void verify(size_t N, size_t *d_A)
{
    for (size_t i = 0; i < N; i++)
    {
        // assert(h_A[i] == i);
        if (d_A[i] != i)
        {
            printf("%lu != %lu\n", d_A[i], i);
        }
    }
}

void test_managed()
{
    cudaDeviceProp prop; // CUDA device properties variable
    checkCuda(cudaGetDeviceProperties(&prop, 0));
    // size_t N = prop.totalGlobalMem - 1024 * 1024 * 1024;
    size_t N = 10 * 1024 * 1024 * 1024L;
    size_t N_entries = N / sizeof(size_t);
    size_t *d_A;

    checkCuda(cudaMallocManaged(&d_A, N));
    memset(d_A, UCHAR_MAX, N);

    // size_t *h_A = (size_t *)malloc(N);
    // memset(h_A, UCHAR_MAX, N);

    // checkCuda(cudaMalloc(&d_A, N));
    // checkCuda(cudaMemcpy(d_A, h_A, N, cudaMemcpyHostToDevice));

    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
    kernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, N_entries);
    checkCuda(cudaDeviceSynchronize());

    // checkCuda(cudaMemcpy(h_A, d_A, N, cudaMemcpyDeviceToHost));
    verify(N_entries, d_A);

    checkCuda(cudaFree(d_A));
    // free(h_A);
};

void test_native()
{
    cudaDeviceProp prop; // CUDA device properties variable
    checkCuda(cudaGetDeviceProperties(&prop, 0));
    // size_t N = prop.totalGlobalMem - 1024 * 1024 * 1024;
    size_t N = 10 * 1024 * 1024 * 1024L;
    size_t N_entries = N / sizeof(size_t);
    size_t *d_A;

    size_t *h_A = (size_t *)malloc(N);
    memset(h_A, UCHAR_MAX, N);

    checkCuda(cudaMalloc(&d_A, N));
    checkCuda(cudaMemcpy(d_A, h_A, N, cudaMemcpyHostToDevice));

    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
    kernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, N_entries);
    checkCuda(cudaDeviceSynchronize());

    checkCuda(cudaMemcpy(h_A, d_A, N, cudaMemcpyDeviceToHost));
    verify(N_entries, h_A);

    checkCuda(cudaFree(d_A));
    free(h_A);
};

int main(int argc, char const *argv[])
{
    test_managed();
    // test_native();
    return 0;
}
