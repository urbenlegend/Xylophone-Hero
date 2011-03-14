
/*******************************************************************
*
* CAUTION: This file is automatically generated by libgen.
* Version: Xilinx EDK 9.2 EDK_Jm.16
* DO NOT EDIT.
*
* Copyright (c) 2005 Xilinx, Inc.  All rights reserved. 
* 
* Description: Driver parameters
*
*******************************************************************/

#define STDIN_BASEADDRESS 0x40600000
#define STDOUT_BASEADDRESS 0x40600000

/******************************************************************/

/* Definitions for driver OPBARB */
#define XPAR_XOPBARB_NUM_INSTANCES 1

/* Definitions for peripheral OPB */
#define XPAR_OPB_BASEADDR 0xFFFFFFFF
#define XPAR_OPB_HIGHADDR 0x00000000
#define XPAR_OPB_DEVICE_ID 0
#define XPAR_OPB_NUM_MASTERS 1


/******************************************************************/

/* Definitions for driver UARTLITE */
#define XPAR_XUARTLITE_NUM_INSTANCES 1

/* Definitions for peripheral RS232_UART_1 */
#define XPAR_RS232_UART_1_BASEADDR 0x40600000
#define XPAR_RS232_UART_1_HIGHADDR 0x4060FFFF
#define XPAR_RS232_UART_1_DEVICE_ID 0
#define XPAR_RS232_UART_1_BAUDRATE 9600
#define XPAR_RS232_UART_1_USE_PARITY 0
#define XPAR_RS232_UART_1_ODD_PARITY 0
#define XPAR_RS232_UART_1_DATA_BITS 8


/******************************************************************/


/* Canonical definitions for peripheral RS232_UART_1 */
#define XPAR_UARTLITE_0_DEVICE_ID XPAR_RS232_UART_1_DEVICE_ID
#define XPAR_UARTLITE_0_BASEADDR 0x40600000
#define XPAR_UARTLITE_0_HIGHADDR 0x4060FFFF
#define XPAR_UARTLITE_0_BAUDRATE 9600
#define XPAR_UARTLITE_0_USE_PARITY 0
#define XPAR_UARTLITE_0_ODD_PARITY 0
#define XPAR_UARTLITE_0_DATA_BITS 8


/******************************************************************/

/* Definitions for driver IIC */
#define XPAR_XIIC_NUM_INSTANCES 1

/* Definitions for peripheral I2C */
#define XPAR_I2C_DEVICE_ID 0
#define XPAR_I2C_BASEADDR 0x40800000
#define XPAR_I2C_HIGHADDR 0x4080FFFF
#define XPAR_I2C_TEN_BIT_ADR 0
#define XPAR_I2C_GPO_WIDTH 2


/******************************************************************/


/* Canonical definitions for peripheral I2C */
#define XPAR_IIC_0_DEVICE_ID XPAR_I2C_DEVICE_ID
#define XPAR_IIC_0_BASEADDR 0x40800000
#define XPAR_IIC_0_HIGHADDR 0x4080FFFF
#define XPAR_IIC_0_TEN_BIT_ADR 0
#define XPAR_IIC_0_GPO_WIDTH 2


/******************************************************************/


/* Definitions for peripheral PLB_BRAM_IF_CNTLR_1 */
#define XPAR_PLB_BRAM_IF_CNTLR_1_BASEADDR 0xffff0000
#define XPAR_PLB_BRAM_IF_CNTLR_1_HIGHADDR 0xffffffff


/******************************************************************/

#define XPAR_CPU_PPC405_CORE_CLOCK_FREQ_HZ 100000000

/******************************************************************/

#define XPAR_CPU_ID 0
#define XPAR_PPC405_ID 0
#define XPAR_PPC405_CORE_CLOCK_FREQ_HZ 100000000
#define XPAR_PPC405_ISOCM_DCR_BASEADDR 0x00000010
#define XPAR_PPC405_ISOCM_DCR_HIGHADDR 0x00000013
#define XPAR_PPC405_DSOCM_DCR_BASEADDR 0x00000020
#define XPAR_PPC405_DSOCM_DCR_HIGHADDR 0x00000023
#define XPAR_PPC405_DISABLE_OPERAND_FORWARDING 1
#define XPAR_PPC405_DETERMINISTIC_MULT 0
#define XPAR_PPC405_MMU_ENABLE 1
#define XPAR_PPC405_DCR_RESYNC 0
#define XPAR_PPC405_HW_VER "2.00.c"

/******************************************************************/
