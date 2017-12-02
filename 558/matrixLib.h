#ifndef MATRIXLIB
#define MATRIXLIB

typedef struct __attribute__((__packed__)){
    float* values;
    int rows;
    int cols;
} matrix_t;

//prototypes go here
matrix_t createMatrix(int rows, int cols, float initialValue);
void copyMatrix(matrix_t *original, matrix_t *copy);
void printMatrix(matrix_t *mat);
void set(matrix_t *mat, int row, int col, float value);
double get(matrix_t *mat, int row, int col);
matrix_t matrixMult(matrix_t *matA, matrix_t *matB);
matrix_t matrixAdd(matrix_t* matA, matrix_t* matB);



#endif 
