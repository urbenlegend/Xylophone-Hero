#include <xuartlite_l.h>
#include "uart.h"

static Xuint32 UART_BaseAddress;


void uartInit(Xuint32 base_address) {
	UART_BaseAddress = base_address;
}

Xuint8 uartScan() {
	Xuint32 status = XIo_In32(UART_BaseAddress + 8); 
	if( status & 1 )
	return uartRead();
	else
	return 0;
} 

Xuint8 uartReadEcho() {
	Xuint8 c = XUartLite_RecvByte(UART_BaseAddress);
	uartWrite(c); 
	return c;
}

Xuint8 uartRead() {
	return XUartLite_RecvByte(UART_BaseAddress);
}

void uartWrite(Xuint8 data) {
	XUartLite_SendByte(UART_BaseAddress, data);
}

void clearUartScreen() {
	uartWrite(0x1B);
	uartWrite('[');
	uartWrite('2');
	uartWrite('J');
}

void getQuitInput(void) {
	char s = '0';

	print("\r\n  <Type q to return to menu> ");

	do{
		s = uartRead();
	} while (s != 'q');

	clearUartScreen();
	return;
}
