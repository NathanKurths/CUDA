#include <stdio.h>

<<<<<<< HEAD
__global__ void helloFromGPU() {
    printf("Hello World from GPU!\n");
}

int main() {
    printf("Hello World from CPU!\n");
    
    helloFromGPU<<<1, 1>>>();
    
    cudaDeviceSynchronize();
    
=======
__global__ void helloWorld()
{
    printf("Hello, World from GPU!\n");
}

int main()
{
    helloWorld<<<3, 10>>>();
    cudaDeviceSynchronize();
>>>>>>> f6faf68 (att)
    return 0;
}
