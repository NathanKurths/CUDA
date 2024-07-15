#include<stdio.h>

int *a, *b, *c;

__global__ void block()
{
    int i = blockIdx.x;
    printf("Hi I am the block %d\n", i);
}

int main()
{
    cudaDeviceReset();

    block<<<13,1>>>();

    cudaDeviceSynchronize();

    return 0;
}