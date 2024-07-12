#include <stdio.h>

int *a, *b, *c; // host data

__global__ void vecAdd(int *a, int *b, int *c)
{
    int i = threadIdx.x;
    c[i] = a[i] + b[i];
}

int main()
{
    cudaDeviceReset();
    int *d_a, *d_b, *d_c;
    int n = 256;
    int size = n * sizeof(int);

    a = (int*)malloc(size);
    b = (int*)malloc(size);
    c = (int*)malloc(size);


    //malloc da gpu
    cudaMalloc((void**)&d_a,size);
    cudaMalloc((void**)&d_b,size);
    cudaMalloc((void**)&d_c,size);

    for (int i = 0; i<n; i++)
    {
        a[i] = i;
        b[i] = i;
    }

    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

    vecAdd <<<1,n>>>(d_a, d_b, d_c);
    cudaDeviceSynchronize();

    cudaMemcpy(c, d_c, size, cudaMemcpyHostToHost);

    printf("\n Resultado da soma: \n");
    for(int i=0; i < n; i++)
    {
        printf(" %d,", c[i]);
    }

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}