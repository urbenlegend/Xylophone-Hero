#include "xparameters.h"
#include "xutil.h"
#include "uart.h"

int main ()
{
	uartInit((void *) 0x40600000);
	uartWrite("Hellow world\r\n");
}

