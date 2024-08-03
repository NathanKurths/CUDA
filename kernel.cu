#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

// Macro para verificar erros CUDA
#define cudaCheckError() {                                           \
    cudaError_t e = cudaGetLastError();                              \
    if (e != cudaSuccess) {                                          \
        printf("CUDA error: %s:%d: '%s'\n", __FILE__, __LINE__,      \
               cudaGetErrorString(e));                               \
        exit(EXIT_FAILURE);                                          \
    }                                                                \
}

__global__ void VecAdd(float* A, float* B, float* C, int N)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i < N)
        C[i] = A[i] + B[i];
}

int main()
{
    cudaDeviceReset();

    float *d_a, *d_b, *d_c;
    float *a, *b, *c;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int n = 4096;
    int size = n * sizeof(float);

    // Alocação de memória para os vetores no host
    a = (float*)malloc(size);
    b = (float*)malloc(size);
    c = (float*)malloc(size);

    // Inicialização dos vetores a e b
    for (int i = 0; i < n; i++) {
        a[i] = i;
        b[i] = i;
    }

    // Alocação de memória para os vetores no dispositivo
    cudaMalloc((void**)&d_a, size);
    cudaMalloc((void**)&d_b, size);
    cudaMalloc((void**)&d_c, size);
    cudaCheckError();

    // Cópia dos vetores a e b do host para o dispositivo
    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);
    cudaCheckError();

    // Início do evento
    cudaEventRecord(start, 0);

    // Definição do grid e dos blocos
    int threadsPerBlock = 1024;
    int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock;

    // Execução do kernel
    VecAdd<<<blocksPerGrid, threadsPerBlock>>>(d_a, d_b, d_c, n);
    cudaDeviceSynchronize();
    cudaCheckError();

    // Fim do evento
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);

    // Cálculo do tempo decorrido
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);
    printf("Elapsed time: %3.3f ms\n", elapsedTime);

    // Cópia do vetor c do dispositivo para o host
    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
    cudaCheckError();

    // Verificação dos resultados
    for (int i = 0; i < n; i++) {
        if (c[i] != a[i] + b[i]) {
            printf("Erro no resultado! c[%d] = %f\n", i, c[i]);
            break;
        }
    }

    // Destruir os eventos
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    // Liberar memória alocada no dispositivo
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Liberar memória alocada no host
    free(a);
    free(b);
    free(c);

    return 0;
}
