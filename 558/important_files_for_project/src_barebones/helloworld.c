/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "matrixLib.h"
#include <xuartps.h>
#include <xuartps_hw.h>

//defines
#define SEND_TIMEOUT 1000
#define RECV_TIMEOUT 1000
#define MESSAGE_LENGTH 9
#define PENDULUM_START_LOWER_BOUND -0.017453
#define PENDULUM_START_UPPER_BOUND 0.017453

//Prototypes
void observer(matrix_t* matA, matrix_t* matB, matrix_t* matC, matrix_t* currentStateN, matrix_t* currentStateU, matrix_t* nextState);
void init_matricies();
int init_our_uart();
int uart0_sendBuffer(XUartPs *InstancePtr, u8 *data, size_t num_bytes);
int uart0_recvBuffer(XUartPs *InstancePtr, u8 *buffer, size_t num_bytes);
int uart_read(u8 buffer[MESSAGE_LENGTH]);
void buffer_to_matrix(matrix_t* sensorData, u8 recv_buffer[MESSAGE_LENGTH]);
void calc_LQR(matrix_t* voltage, matrix_t* x_next, matrix_t* x_current, matrix_t* sensorData);
void transmit_voltage(matrix_t* voltage);
void uart_send( u16 data);

//Globals
XUartPs uart0;		/* The instance of the UART Driver */
matrix_t matA;
matrix_t matB;
matrix_t matC;
matrix_t matD;
matrix_t matK;

int main()
{
    init_platform();

    int i;
    for(i=0; i<3; i++){
    	xil_printf("God Damn it!\n");
    }

    //initialize variables
    matA = createMatrix(2, 2, 0);
    matB = createMatrix(2, 3, 0);
    matC = createMatrix(4, 2, 0);
    matD = createMatrix(4, 2, 0);
    matK = createMatrix(1, 4, 0);
    matrix_t voltage = createMatrix(1, 1, 0);
    matrix_t x_next = createMatrix(2, 1, 0);
    matrix_t x_current = createMatrix(2, 1, 0);
    matrix_t sensorData = createMatrix(2, 1 ,0);

    //setup constant matricies
    init_matricies(matA, matB, matC, matD, matK);
    init_our_uart();

    u8 recv_buffer[MESSAGE_LENGTH];
    memset(recv_buffer, 0, MESSAGE_LENGTH);


    //initialize sensorData
    uart_read(recv_buffer);
	buffer_to_matrix(&sensorData, recv_buffer);
	float pendulumRadians = get(&sensorData, 1, 0);

    //Don't start until the pendulum is brought upright.
    while( pendulumRadians < PENDULUM_START_LOWER_BOUND || pendulumRadians > PENDULUM_START_UPPER_BOUND ){
    	//get data from sensors
		uart_read(recv_buffer);
		buffer_to_matrix(&sensorData, recv_buffer);
		pendulumRadians = get(&sensorData, 1, 0);
    }


    xil_printf("Starting while loop\n");
	while(pendulumRadians > 10*PENDULUM_START_LOWER_BOUND && pendulumRadians < 10*PENDULUM_START_UPPER_BOUND){
		//get data from sensors
		int bytes_recv = uart_read(recv_buffer);
		buffer_to_matrix(&sensorData, recv_buffer);


		// put them into the LQR
		calc_LQR(&voltage, &x_next, &x_current, &sensorData);

		transmit_voltage(&voltage);


		//gain multipication
		//add sensed inputs and new velocties
		//send downward

		//calculate error between where cart is and where we want it to between

		//convert error to voltage
		//clamp voltage, 0
		//DAC



		//int bytes_recv = uart0_recvBuffer(&uart0, recv_buffer, sizeof(recv_buffer) );
		//int bytes_recv = uart_read(&uart0, recv_buffer);
		//xil_printf("Received %d bytes..\n", bytes_recv);
		//buffer_to_matrix(&sensorData, recv_buffer);

		//xil_printf("%X %X\n", recv_buffer[4] << 24 | recv_buffer[3] << 16 | recv_buffer[2] << 8 | recv_buffer[1],
		//					  recv_buffer[8] << 24 | recv_buffer[7] << 16 | recv_buffer[6] << 8 | recv_buffer[5]);

		//int i;
		//for(i=0; i<MESSAGE_LENGTH; i++){
		//	xil_printf("%X ", recv_buffer[i]);
		//}
		//xil_printf("\n");

		//printf("%f, %f\n", get(&sensorData, 0, 0), get(&sensorData, 1, 0));
		//printf("%f\n", get(&voltage, 0, 0) );

		//update loop condition
		pendulumRadians = get(&sensorData, 1, 0);
	}

	xil_printf("Zybo program stopped\n");
	cleanup_platform();
	return 0;
}


/* observer code */
void calc_LQR(matrix_t* voltage, matrix_t* x_next, matrix_t* x_current, matrix_t* sensorData){
	matrix_t u_ref = createMatrix(4,1,0);

	// LQR calculations
	// Calculations for voltage
	// Voltage = matK * (u_ref - (matD * sensorData + matC * x_current))
	matrix_t temp = matrixMult(&matD, sensorData);	// matD * sensorData
	matrix_t temp2 = matrixMult(&matC, x_current);	// matC * x_current
	matrix_t temp3 = matrixAdd(&temp, &temp2);		// (matD * sensorData + matC * x_current)
	matrix_t temp4 = matrixSub(&u_ref, &temp3);		// u_ref - (matD * sensorData + matC * x_current)
	matrix_t temp5 = matrixMult(&matK, &temp4);		// matK * (u_ref - (matD * sensorData + matC * x_current)) = Voltage
	copyMatrix(&temp5, voltage);

	// Calculations for x_next
	// x_next = matA * x_current + matB * [sensorData; voltage]
	temp = createMatrix(3, 1, 0);					// empty matrix for [sensorData; voltage] concatenation
	set(&temp, 0, 0, get(sensorData, 0, 0));		// assigning sensorData(1) into first row of temp
	set(&temp, 1, 0, get(sensorData, 1, 0));		// assigning sensorData(2) into second row of temp
	set(&temp, 2, 0, get(voltage, 0, 0));			// assigning voltage into third row of temp
	temp2 = matrixMult(&matB, &temp);				// matB * [sensorData; voltage]
	temp3 = matrixMult(&matA, x_current);			// matA * x_current
	temp4 = matrixAdd(&temp2, &temp3);				// matA * x_current + matB * [sensorData; voltage]
	copyMatrix(&temp4, x_next);						// x_next = matA * x_current + matB * [sensorData; voltage]

	copyMatrix(x_next, x_current);					// x_current = x_next

}

void init_matricies(){
	set(&matA, 0, 0, 0.928);
	set(&matA, 0, 1, 0.0);
	set(&matA, 1, 0, 0.0);
	set(&matA, 1, 1, 0.928);

	set(&matB, 0, 0, 0.27);
	set(&matB, 0, 1, 0.016);
	set(&matB, 0, 2, 0.0146);
	set(&matB, 1, 0, 1.83);
	set(&matB, 1, 1, -0.273);
	set(&matB, 1, 2, 0.0336);

	set(&matC, 0, 0, 0.0);
	set(&matC, 0, 1, 0.0);
	set(&matC, 1, 0, 0.0);
	set(&matC, 1, 1, 0.0);
	set(&matC, 2, 0, 1.0);
	set(&matC, 2, 1, 0.0);
	set(&matC, 3, 0, 0.0);
	set(&matC, 3, 1, 1.0);

	set(&matD, 0, 0, 1.0);
	set(&matD, 0, 1, 0.0);
	set(&matD, 1, 0, 0.0);
	set(&matD, 1, 1, 1.0);
	set(&matD, 2, 0, -3.74);
	set(&matD, 2, 1, 0.003);
	set(&matD, 3, 0, -25.26);
	set(&matD, 3, 1, 7.28);

	set(&matK, 0, 0, -60.5);
	set(&matK, 0, 1, 136.62);
	set(&matK, 0, 2, -47.94);
	set(&matK, 0, 3, 26.12);

}

int init_our_uart(){
	int status;
	XUartPs_Config *Config;
	xil_printf("Ready to Start Uart crap\r\n");
	/*
	 * Initialize the UART driver so that it's ready to use
	 * Look up the configuration in the config table and then initialize it.
	 */
	Config = XUartPs_LookupConfig(XPAR_PS7_UART_0_DEVICE_ID);
	if (Config == NULL) {
		return XST_FAILURE;
	}
	xil_printf("Look up Config Success\n");

	status = XUartPs_CfgInitialize(&uart0, Config, Config->BaseAddress);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XUartPs_SetBaudRate(&uart0, 115200);

	xil_printf("Initialize Config Success\n");
	return status;
}

int uart_read(u8 buffer[MESSAGE_LENGTH]){
	memset(buffer, 0, MESSAGE_LENGTH);
	int bytes_recv = 0;

	// wait until we see the start of the next message
	// The start is specified by the byte 0xA5
	while(buffer[bytes_recv] != 0xA5){
		if(XUartPs_IsReceiveData(uart0.Config.BaseAddress)){
			buffer[bytes_recv] = XUartPs_RecvByte(uart0.Config.BaseAddress);
		}
	}

	bytes_recv = 1;
	// should receive 9 bytes. 4 bytes ADC * 2 ADCs + 1 start byte
	while(bytes_recv < MESSAGE_LENGTH){
		if(XUartPs_IsReceiveData(uart0.Config.BaseAddress)){
			//index starts at 1 because buffer[0] should be the start of the message
			buffer[bytes_recv] = XUartPs_RecvByte(uart0.Config.BaseAddress);
			++bytes_recv;
		}
	}

	return bytes_recv;

}

void buffer_to_matrix(matrix_t* sensorData, u8 recv_buffer[MESSAGE_LENGTH]){
	int encoder1 = recv_buffer[4] << 24 | recv_buffer[3] << 16 | recv_buffer[2] << 8 | recv_buffer[1] ;
	int encoder2 = recv_buffer[8] << 24 | recv_buffer[7] << 16 | recv_buffer[6] << 8 | recv_buffer[5] ;

	//convert encoder1 ticks to a distance in meters
	float metersPerTicks = 1.0 / 44810.0;

	//conert encoder2 ticks to
	float radsPerTick = 1.0 / 650.625;

	set(sensorData, 0, 0, (float)(encoder1*metersPerTicks));
	//bias the encoder2 value because up should be 0. Down should not be 0.
	set(sensorData, 1, 0, (float)(encoder2*radsPerTick) - 3.1415);
}
void transmit_voltage(matrix_t* voltage){
	float volt = get(voltage, 0, 0);
	if(volt > 10.0) volt = 10.0;
	if(volt < -10.0) volt = -10.0;

	u16 voltTX = (65535/20.0 * volt) + 32768;

	uart_send(voltTX);

}


void uart_send( u16 data) {
	XUartPs_SendByte(uart0.Config.BaseAddress, 0xA5);
	XUartPs_SendByte(uart0.Config.BaseAddress, data & 0x00FF);
	XUartPs_SendByte(uart0.Config.BaseAddress, data >> 8);
}


//Dont use this. It is just here for Kyle to remember how to read the UART.
/*
 * Recv a buffer one byte at a time. With a timeout specified by SEND_TIMEOUT.
 *
 * returns number of bytes received
 */
int uart0_recvBuffer(XUartPs *InstancePtr, u8 *buffer, size_t num_bytes) {
	int bytes_recv = 0;
		int iterations = 0;
		int found_data = 0;

		memset(buffer, 0, num_bytes);

		/*
		 * Two stages:
		 * 1) Wait for first piece of data. Could be different waiting period than stage 2.
		 * 2) Data should be coming in now. While it is coming in, read it character by character
		 * 	  and save it into a larger buffer (the one we pass in). When we haven't seen any new
		 * 	  data for a long time, consider that the end of the data and return from function.
		 *
		 */
		iterations = 0;
		while(iterations < 2000000){
			if(XUartPs_IsReceiveData(InstancePtr->Config.BaseAddress)){
				found_data = 1;
				//xil_printf("found first data");
				break;
			}
			iterations++;
		}

		iterations = 0;
		if(found_data){
			while(iterations < 100000 ){
				if(bytes_recv > num_bytes)
					break;
				if(XUartPs_IsReceiveData(InstancePtr->Config.BaseAddress)){
					buffer[bytes_recv] = XUartPs_RecvByte(InstancePtr->Config.BaseAddress);
					iterations = 0;
					bytes_recv++;
				}

				iterations++;
			}
		}

		return bytes_recv;
}
