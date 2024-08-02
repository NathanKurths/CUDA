#include <stdio.h>

// Kernel CUDA
__global__ void copy_vector(float *data, int N) {
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    int aux = 0;

    // Define memória compartilhada com tamanho do bloco
    __shared__ float temp_data[256];

    // Garantir que o índice não saia dos limites
    if (index < N) {
        temp_data[threadIdx.x] = data[index];

        __syncthreads();

        // Calcula a soma parcial para o bloco
        for (int i = 0; i < blockDim.x; i++) {
            aux += temp_data[i];
        }

        // Escreve o resultado de volta na memória global
        data[index] = aux;
    }
}

int main() {
    int N = 1024;  // Tamanho do vetor
    size_t size = N * sizeof(float);

    // Aloca memória no host
    float *h_data = (float *)malloc(size);
    for (int i = 0; i < N; i++) {
        h_data[i] = 1.0f;  // Inicializa com 1 para teste
    }

    // Aloca memória no device
    float *d_data;
    cudaMalloc(&d_data, size);

    // Copia dados do host para o device
    cudaMemcpy(d_data, h_data, size, cudaMemcpyHostToDevice);

    // Define o número de blocos e threads por bloco
    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    // Executa o kernel
    copy_vector<<<blocksPerGrid, threadsPerBlock>>>(d_data, N);

    // Copia o resultado de volta para o host
    cudaMemcpy(h_data, d_data, size, cudaMemcpyDeviceToHost);

    // Verifica o resultado
    for (int i = 0; i < N; i++) {
        printf("%f ", h_data[i]);
    }
    printf("\n");

    cudaFree(d_data);
    free(h_data);

    return 0;
}
