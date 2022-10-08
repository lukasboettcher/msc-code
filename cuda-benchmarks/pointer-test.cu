#include "stdio.h"

__managed__ int* x;

__global__ void kernel(int *a)
{
    a[0] = 10;
    x[0] = 100; 
}

int main(int argc, char const *argv[])
{
    int *host_ptr, *device_ptr;
    cudaHostAlloc(&host_ptr, sizeof(int), 0 | 0); // cudaHostAllocMapped
    x = host_ptr;
    cudaHostGetDevicePointer(&device_ptr, host_ptr, 0);
    kernel<<<1, 1>>>(host_ptr);
    cudaDeviceSynchronize();

    printf("host ptr: %p\n", host_ptr);
    printf("device ptr: %p\n", device_ptr);
    printf("%i\n", x[0]);
    return 0;
}
