#ifndef MATRIXLIB
#define MATRIXLIB

typedef struct __attribute__((__packed__)){
    double* values;
    int rows;
    int cols;
} matrix_t;

//prototypes go here
matrix_t createMatrix(int rows, int cols);
void copyMatrix(matrix_t *original, matrix_t *copy);
void printMatrix(matrix_t *mat);
void set(matrix_t *mat, int row, int col, double value);
double get(matrix_t *mat, int row, int col);
matrix_t matrixMult(matrix_t *matA, matrix_t *matB);



#endif 
