#include <stdio.h>

int main()
{
    cudaDeviceReset();
    int *d_a, *d_b, *d_c;

    cudaEvent_t start, stop;

    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int n = 4096;
    int size = n * sizeof(int);

    a = (int*)malloc(size);
    b = (int*)malloc(size);
    c = (int*)malloc(size);

    cudaMalloc((void**)&d_a, size);
    cudaMalloc((void**)&d_b, size);
    cudaMalloc((void**)&d_c, size);

    for (int i =0; i < n; i++)
        a[i] = i, b[i] = i;

    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

    cudaEventRecord(start, 0);

    vecAdd <<< ceil (n/1024), 1024  >>> (n, d_a, d_b, d_c);
    cudaDeviceSynchronize();
}