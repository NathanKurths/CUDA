#include <stdio.h>
__global__ void meuKernel (int *a, int *b, int *c)
{
    *c = *a + *b;
}

int main(){
    cudaDeviceReset();
    int a, b, c;
    int *d_a, *d_b, *d_c;
    int size = sizeof(int);

    cudaMalloc((void**)&d_a, size);
    cudaMalloc((void**)&d_b, size);
    cudaMalloc((void**)&d_c, size);

    a = 2;
    b = 7;

    cudaMemcpy(d_a, &a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, &b, size, cudaMemcpyHostToDevice);

    meuKernel<<<1,1>>>(d_a, d_b, d_c);
    cudaDeviceSynchronize();

    cudaMemcpy(&c, d_c, size, cudaMemcpyDeviceToHost);

    printf("%d + %d = %d\n", a, b, c);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}