#include "matrixLib.h"
#include <stdlib.h>
#include <stdio.h>

/* creates a matrix and initializes it with all 0.0 */
matrix_t createMatrix(int rows, int cols){
    matrix_t mat;
    mat.rows = rows;
    mat.cols = cols;
    mat.values = (double*) malloc(sizeof(double) * rows * cols);
    int i;
    for(i=0; i<rows*cols; i++){
        mat.values[i] = 0.0;
    }
    return mat;
}

/* copy the data from mat into matA */
void copyMatrix(matrix_t *original, matrix_t *copy){
    *copy = *original;
    /*
    //This is how to copy the matix if it is not a packed struct
    copy->rows = original->rows;
    copy->cols = original->cols;
    int i;
    for(i=0; i< original->rows*original->cols; i++){
        copy->values[i] = original->values[i];
    }
    */
}

/* prints a matrix in rows and columns */
void printMatrix(matrix_t *mat){
    int i,j;
    for(i=0; i<mat->rows; i++){
        printf("[");
        for(j=0; j<mat->cols; j++){
            printf("%.3lf ", get(mat, i, j) );
        }
    printf("]");
        printf("\n");
    }
    printf("\n");
}

/* assigns value to matrix mat at position (row, col) */
void set(matrix_t *mat, int row, int col, double value){
    mat->values[row*mat->cols + col] = value;
}

/* return the value in matrix mat at position (row, col) */
double get(matrix_t *mat, int row, int col){
    return mat->values[row*mat->cols + col];
}


/* multiply matA * matB. Stores output into matA */
matrix_t matrixMult(matrix_t *matA, matrix_t *matB){
    int i, j, k;
    //it is important that it is initialized to 0.0
    matrix_t matrixOut = createMatrix(matA->rows, matB->cols);
    
    for(i=0; i<(matrixOut.rows); i++){
        for(j=0; j<(matrixOut.cols); j++){
            double value = 0.0;
            for(k=0; k<(matA->cols); k++){
               value +=  ( get(matA, i, k) * get(matB, k, j) );
                //printf("i=%d, j=%d, k=%d, value=%lf\n",i, j, k, value);
                //printf("matA(%d, %d)=%lf, matB(%d, %d)=%lf\n", i, k, get(matA, i, k), k, j, get(matB, k, j));
                
            }
            set(&matrixOut, i, j, value);
        }
    }
    
    return matrixOut;
}
