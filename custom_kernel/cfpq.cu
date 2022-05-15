#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <bits/stdc++.h>

using namespace std;

#define BLOCK_SIZE 32

#define checkCuda(val) check((val), #val, __FILE__, __LINE__)
template <typename T>
void check(T err, const char *const func, const char *const file,
           const int line)
{
    if (err != cudaSuccess)
    {
        std::cerr << "CUDA Runtime Error at: " << file << ":" << line
                  << std::endl;
        std::cerr << cudaGetErrorString(err) << " " << func << std::endl;
        std::exit(EXIT_FAILURE);
    }
}

template <typename T>
__global__ void gpu_matrix_mult(T *a, T *b, T *c, size_t m, size_t n, size_t k)
{
    size_t row = blockIdx.y * blockDim.y + threadIdx.y;
    size_t col = blockIdx.x * blockDim.x + threadIdx.x;
    T sum = 0;
    if (col < k && row < m)
    {
        for (size_t i = 0; i < n; i++)
        {
            sum += a[row * n + i] * b[i * k + col];
        }
        c[row * k + col] = sum;
    }
}

template <typename T>
__device__ T get_lhs(T const a, T const b){
    T res = 0;

    // lsb   = a
    // lsb+1 = b
    // lsb+2 = c

    if (a & 1<<0 && b & 1<<1)
    {
        res |= 1<<2;
    }
    
    return res;
}

__device__ int d_changed;

template <typename T>
__global__ void closure_kernel(T *a, size_t V)
{
    size_t row = blockIdx.y * blockDim.y + threadIdx.y;
    size_t col = blockIdx.x * blockDim.x + threadIdx.x;
    T sum = 0;
    if (col < V && row < V)
    {
        for (size_t i = 0; i < V; i++)
        {
            // sum += a[row * n + i] * b[i * k + col];
            sum |= get_lhs(a[row * V + i], a[i * V + col]);
            // sum |= a[row * V + i] & a[i * V + col];
        }
        a[row * V + col] = sum;
    }
}

template <typename T>
__global__ void closure_kernel_blocked(T *d_a, size_t n)
{
    __shared__ T tile_a[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ T tile_b[BLOCK_SIZE][BLOCK_SIZE];

    size_t row = blockIdx.y * BLOCK_SIZE + threadIdx.y;
    size_t col = blockIdx.x * BLOCK_SIZE + threadIdx.x;
    T tmp = 0;
    size_t idx;

    for (size_t sub = 0; sub < gridDim.x; ++sub)
    {
        idx = row * n + sub * BLOCK_SIZE + threadIdx.x;
        if (idx >= n * n)
        {
            tile_a[threadIdx.y][threadIdx.x] = 0;
        }
        else
        {
            tile_a[threadIdx.y][threadIdx.x] = d_a[idx];
        }

        idx = (sub * BLOCK_SIZE + threadIdx.y) * n + col;
        if (idx >= n * n)
        {
            tile_b[threadIdx.y][threadIdx.x] = 0;
        }
        else
        {
            tile_b[threadIdx.y][threadIdx.x] = d_a[idx];
        }
        __syncthreads();

        for (int k = 0; k < BLOCK_SIZE; ++k)
        {
            tmp |= get_lhs(tile_a[threadIdx.y][k], tile_b[k][threadIdx.x]);
            // tmp += tile_a[threadIdx.y][k] * tile_b[k][threadIdx.x];
        }
        __syncthreads();
    }
    if (row < n && col < n)
    {
        d_a[row * n + col] = tmp;
    }
}

template <typename T>
void printMatrix(T *m, size_t ld)
{
    for (size_t i = 0; i < ld; i++)
    {
        for (size_t j = 0; j < ld; j++)
        {
            T val = m[i * ld + j];
            // printbits(val);
            // putchar(' ');
            cout << val << "\t";
        }
        cout << endl;
    }
    cout << endl;
}

int main(int argc, char const *argv[])
{
    typedef unsigned char myType;
    srand(3333);

    size_t V{1<<16}, freeMem, totalMem;
    checkCuda(cudaMemGetInfo(&freeMem, &totalMem));
    cout << "free memory:\t" << (double)freeMem/(1024*1024) << " MiB" << endl;
    cout << "needed memory:\t" << (double)(sizeof(myType) * V * V)/(1024*1024) << " MiB" << endl;
    

    // allocate memory in host RAM, h_cc is used to store CPU result
    // myType *h_a, *h_b, *h_c, *cpu_check;
    myType *h_a, *d_a;
    checkCuda(cudaMallocHost((void **)&h_a, sizeof(myType) * V * V));
    // checkCuda(cudaMallocHost((void **)&h_b, sizeof(myType) * V * V));
    // checkCuda(cudaMallocHost((void **)&h_c, sizeof(myType) * V * V));
    // checkCuda(cudaMallocHost((void **)&cpu_check, sizeof(myType) * V * V));

    // random initialize matrix A
    for (int i = 0; i < V; ++i)
    {
        for (int j = 0; j < V; ++j)
        {
            h_a[i * V + j] = rand();
            // h_b[i * V + j] = 0;
        }
    }

    // // random initialize matrix B
    // for (int i = 0; i < V; ++i)
    // {
    //     for (int j = 0; j < V; ++j)
    //     {
    //         h_b[i * V + j] = rand() %3;
    //     }
    // }

    // h_a[1] = 1;
    // h_a[3] = 2;

    // printMatrix(h_a, V);
    // printMatrix(h_b, V);

    cudaEvent_t startEvent, stopEvent;
    float time{0.0f};

    checkCuda(cudaEventCreate(&startEvent));
    checkCuda(cudaEventCreate(&stopEvent));

    // // Allocate memory space on the device
    // myType *d_a, *d_b, *d_c;

    checkCuda(cudaMalloc((void **)&d_a, sizeof(myType) * V * V));
    // checkCuda(cudaMalloc((void **)&d_b, sizeof(myType) * V * V));
    // checkCuda(cudaMalloc((void **)&d_c, sizeof(myType) * V * V));

    // copy matrix A and B from host to device memory
    checkCuda(cudaMemcpy(d_a, h_a, sizeof(myType) * V * V, cudaMemcpyHostToDevice));
    // checkCuda(cudaMemcpy(d_b, h_b, sizeof(myType) * V * V, cudaMemcpyHostToDevice));

    size_t grid_rows = (V + BLOCK_SIZE - 1) / BLOCK_SIZE;
    size_t grid_cols = (V + BLOCK_SIZE - 1) / BLOCK_SIZE;
    dim3 dimGrid(grid_cols, grid_rows);
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);

    checkCuda(cudaEventRecord(startEvent, 0));
    // gpu_square_matrix_mu<lt<<<dimGrid, dimBlock>>>(d_a, d_b, d_c, V);
    // closure_kernel<<<dimGrid, dimBlock>>>(d_a, V);
    closure_kernel_blocked<<<dimGrid, dimBlock>>>(d_a, V);
    checkCuda(cudaEventRecord(stopEvent, 0));
    checkCuda(cudaEventSynchronize(stopEvent));
    checkCuda(cudaEventElapsedTime(&time, startEvent, stopEvent));

    typeof(d_changed) h_changed;
    cudaMemcpyFromSymbol(&h_changed, "d_changed", sizeof(h_changed), 0, cudaMemcpyDeviceToHost);

    // Transefr results from device to host
    checkCuda(cudaMemcpy(h_a, d_a, sizeof(myType) * V * V, cudaMemcpyDeviceToHost));
    checkCuda(cudaDeviceSynchronize());

    // printMatrix(h_a, V);

    cout << "time: " << time << endl;

    // free memory
    checkCuda(cudaFree(d_a));
    // checkCuda(cudaFree(d_b));
    // checkCuda(cudaFree(d_c));
    checkCuda(cudaFreeHost(h_a));
    // checkCuda(cudaFreeHost(h_b));
    // checkCuda(cudaFreeHost(h_c));
    // checkCuda(cudaFreeHost(cpu_check));
    return 0;
}
