#ifndef UART_H
#define UART_H

#include <xbasic_types.h>

void uartInit(Xuint32 base_address);
Xuint8 uartScan(void);
Xuint8 uartReadEcho(void);
Xuint8 uartRead(void);
void uartWrite(Xuint8 data);
void clearUartScreen(void);
void getQuitInput(void);

#endif
