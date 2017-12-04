#include <stdio.h>
#include "matrixLib.h"
#include <stdlib.h>
#include <time.h>

void sandbox();
void multiplyDemo();


void main(void){
    sandbox();
    //multiplyDemo();
}

void sandbox(){
    matrix_t matA = createMatrix(2, 2, 0);
    matrix_t matA2 = createMatrix(2, 2, 0);
    matrix_t matB = createMatrix(2, 1, 0);
    matrix_t matC = createMatrix(2, 2, 1);
    
    printf("matA init\n");
    printMatrix(&matA);
    
    
    //assign values without function
    matA.values[0] = 0.0;
    matA.values[1] = 1.0;
    matA.values[2] = 2.0;
    matA.values[3] = 3.0;
    printf("matA assigned directly\n");
    printMatrix(&matA);
    
    copyMatrix(&matA, &matA2);
    printf("copy of matA, aka matA2\n");
    printMatrix(&matA2);
    
    int row = 1, col=1;
    printf("matA(%d,%d) = %lf\n\n", row, col, get(&matA, row, col));
    
    set(&matB, 0, 0, 4.0);
    set(&matB, 0, 1, 5.0);
    printf("matB assigned by function\n");
    printMatrix(&matB);
    
    matA2 = matrixMult(&matA, &matB);
    printf("multiply matA * matB\n");
    printMatrix(&matA2);
    
    printf("______________________\n");
    printf("matA\n");
    printMatrix(&matA);
    printf("matC\n");
    printMatrix(&matC);
    
    
    matC = matrixAdd(&matA, &matC);
    printf("add matA + matC\n");
    printMatrix(&matC);
    
    
}

void multiplyDemo(){
    //srand(time(NULL));
    srand(0);
    matrix_t matA = createMatrix(4, 3, 0);
    matrix_t matB = createMatrix(3, 2, 0);
    
    int i, j;
    for(i=0; i<matA.rows*matA.cols; i++){
        matA.values[i] = (double) (rand()%1000);
    }
    
    for(i=0; i<matB.rows*matB.cols; i++){
        matB.values[i] = (double) (rand()%1000);
    }
    
    printMatrix(&matA);
    printf("*\n\n");
    printMatrix(&matB);
    printf("=\n\n");
    matrix_t matC = matrixMult(&matA, &matB);
    printMatrix(&matC);
}