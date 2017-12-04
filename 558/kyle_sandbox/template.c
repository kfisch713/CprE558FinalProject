#include <stdio.h>
#include "matrixLib.h"

void observer(matrix_t* matA, matrix_t* matB, matrix_t* matC, matrix_t* currentStateN, matrix_t* currentStateU, matrix_t* nextState);

int main(){

    //initialize variables
    matrix_t matA = createMatrix(2,2,0); // model constants
    matrix_t matB = createMatrix(2,3, 0); //sensor info
    matrix_t matC = createMatrix(2,2, 1); //itentity matrix
    matrix_t currentStateN = createMatrix(2,1,0);
    matrix_t currentStateU = createMatrix(3,1,0);
    matrix_t nextState = createMatrix(2,1,0);
    
    int i=0;
    
    while(1){
        //scan sensors
            //ADC
        
        //observer
        observer(&matA, &matB, &matC, &currentStateN, &currentStateU, &nextState);
        i++;
        if(i%999999) printMatrix(&currentStateN);
        
        //gain multipication
        //add sensed inputs and new velocties
        //send downward
        
        //calculate error between where cart is and where we want it to between
        
        //convert error to voltage
        //clamp voltage, 0
        //DAC
        
        
        
    }

}

/* observer code */
void observer(matrix_t* matA, matrix_t* matB, matrix_t* matC, matrix_t* currentStateN, matrix_t* currentStateU, matrix_t* nextState){
    matrix_t tempA = matrixMult(matA, currentStateN);
    matrix_t tempB = matrixMult(matB, currentStateU);
    *nextState =  matrixAdd(&tempA, &tempB);
}