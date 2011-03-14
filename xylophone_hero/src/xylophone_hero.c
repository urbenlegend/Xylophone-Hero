/*
*  * Copyright (c) 2004 Xilinx, Inc.  All rights reserved.
*
* Xilinx, Inc.
* XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A 
* COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
* ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR 
* STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION 
* IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE 
* FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION
* XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO 
* THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO 
* ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE 
* FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY 
* AND FITNESS FOR A PARTICULAR PURPOSE.
*/

// Located in: ppc405_0/include/xparameters.h

#include <xi2c_l.h>
#include <xgpio.h>
#include <xparameters.h>
#include <xutil.h>

#include "characters.h"
#include "uart.h"


#define GPO_REG_OFFSET 0x124
//#define DECODER_ADDR 0x21  //Read: 0x43, Write: 0x42
#define DECODER_ADDR 0x20 //Read: 0x41, Write: 0x40
#define SEND_CNT 3
#define RECV_CNT 3
#define GPO_RESETS_OFF 1
#define GPO_RESET_IIC 3
#define GPO_RESET_DECODER 0

struct VideoModule {
  Xuint8 addr;
  Xuint8 config_val;
  Xuint8 actual_val;
};

#define DECODER_SVID_CONFIG_CNT 17
struct VideoModule decoder_svid[] = { 
  { 0x00, 0x06, 0 },
  { 0x15, 0x00, 0 },
  { 0x27, 0x58, 0 },
  { 0x3a, 0x12, 0 },
  { 0x50, 0x04, 0 },
  { 0x0e, 0x80, 0 },
  { 0x50, 0x20, 0 },
  { 0x52, 0x18, 0 }, 
  { 0x58, 0xed, 0 },
  { 0x77, 0xc5, 0 },
  { 0x7c, 0x93, 0 },
  { 0x7d, 0x00, 0 },
  { 0xd0, 0x48, 0 },
  { 0xd5, 0xa0, 0 },
  { 0xd7, 0xea, 0 },
  { 0xe4, 0x3e, 0 },
  { 0xea, 0x0f, 0 }, 
  { 0x0e, 0x00, 0 } };

#define DECODER_COMP_CONFIG_CNT 18
struct VideoModule decoder_comp[] = { 
  { 0x00, 0x04, 0 },
  { 0x15, 0x00, 0 },
  { 0x17, 0x41, 0 },
  { 0x27, 0x58, 0 },
  { 0x3a, 0x16, 0 }, 
  { 0x50, 0x04, 0 },
  { 0x0e, 0x80, 0 },
  { 0x50, 0x20, 0 },
  { 0x52, 0x18, 0 }, 
  { 0x58, 0xed, 0 },
  { 0x77, 0xc5, 0 },
  { 0x7c, 0x93, 0 },
  { 0x7d, 0x00, 0 },
  { 0xd0, 0x48, 0 },
  { 0xd5, 0xa0, 0 },
  { 0xd7, 0xea, 0 },
  { 0xe4, 0x3e, 0 },
  { 0xea, 0x0f, 0 }, 
  { 0x0e, 0x00, 0 } };


#define DECODER_CMPNT_CONFIG_CNT 13
struct VideoModule decoder_cmpnt[] = { 
  { 0x00, 0x0a, 0 },
  { 0x27, 0xd8, 0 },
  { 0x50, 0x04, 0 },
  { 0x0e, 0x80, 0 },
  { 0x52, 0x18, 0 }, 
  { 0x58, 0xed, 0 },
  { 0x77, 0xc5, 0 },
  { 0x7c, 0x93, 0 },
  { 0x7d, 0x00, 0 },
  { 0xd0, 0x48, 0 },
  { 0xd5, 0xa0, 0 },
  { 0xe4, 0x3e, 0 },
  { 0x0e, 0x00, 0 } };

//
// funtion prototypes
//

void configDecoder(struct VideoModule *decoder, int config_cnt );
void Reset_xup_decoder(void);
void main_memu(void);
unsigned char get_hex_byte();
void edit_i2c_reg(void);





// Function declarations.
static void printSubtitle (char *, unsigned int, unsigned int, int, int);
static void printLetter(char, unsigned int, unsigned int, int, int);
static void drawBox(int, int, int);
static void clearScreen ();
static void sendFrame();
static void itoa (int, char *);

static void mainMenu ();
static void gameMode ();
static void credits ();
static void calibrate ();

// GPIO.
XGpio white_color;
XGpio black_color;
XGpio white_count;
XGpio black_count;
XGpio calib;
XGpio BW;
XGpio frame_start;
XGpio clk_27;
XGpio game_mode;

static Xuint32 white_color_val = 185;
static Xuint32 black_color_val = 64;
static Xuint32 white_count_val = 200;
static Xuint32 black_count_val = 20;
static Xuint32 calib_val = 0;

// Display buffer.
#define DISP_W 720
#define DISP_H 540
#define BUF_W 12
#define BUF_H 270
static Xuint32 frame_buf[BUF_W][BUF_H];

// Program state.
enum {MAIN_MENU, GAME_MODE, CREDITS, CALIBRATE};
int state;

int main (void)
{
	// Initialize camera decoder
	Xuint8 start_addr = 0;
  Xuint8 send_data[SEND_CNT] = {0};
  Xuint32 send_cnt;
  Xuint8 recv_data[RECV_CNT] = {0};
  Xuint32 recv_cnt;
  Xuint8 i;
  int wait_delay = 50000000;

    uartInit(XPAR_RS232_UART_1_BASEADDR);

    XI2c_mWriteReg(XPAR_I2C_BASEADDR, GPO_REG_OFFSET, GPO_RESETS_OFF);// deassert reset to vid decoder
    recv_cnt = 0;
	print("\r\nXUP-V2Pro Video Decoder Expansion Board Video Pass Through Test  ");
    print("\r\nDetecting Video Decoder...\t");
    XI2c_mWriteReg(XPAR_I2C_BASEADDR, GPO_REG_OFFSET, GPO_RESET_IIC);
    XI2c_mWriteReg(XPAR_I2C_BASEADDR, GPO_REG_OFFSET, GPO_RESETS_OFF);
    recv_cnt = XI2c_RSRecv(XPAR_I2C_BASEADDR, DECODER_ADDR, start_addr, 
			   recv_data, 1);
    if( recv_cnt != 1 )
      print("No device detected!\r\n");
    else {
	  configDecoder(decoder_comp, DECODER_COMP_CONFIG_CNT);
      print("Decoder detected! Configuring for composite video -  default.\r\n");
	  Reset_xup_decoder();
	configDecoder(decoder_svid, DECODER_SVID_CONFIG_CNT);
	  }
  
  print("\r\nTest Complete!\r\n\r\n");

	// Initialize ports on FPGA.
	XGpio_Initialize (&white_color, XPAR_WHITE_COLOR_DEVICE_ID);
	XGpio_Initialize (&black_color, XPAR_BLACK_COLOR_DEVICE_ID);
	XGpio_Initialize (&white_count, XPAR_WHITE_COUNT_DEVICE_ID);
	XGpio_Initialize (&black_count, XPAR_BLACK_COUNT_DEVICE_ID);
	XGpio_Initialize (&calib, XPAR_CALIB_DEVICE_ID);
	XGpio_Initialize (&BW, XPAR_BW_DEVICE_ID);
	XGpio_Initialize (&clk_27, XPAR_CLK_27_DEVICE_ID);
	XGpio_Initialize (&frame_start, XPAR_FRAME_DEVICE_ID);
	XGpio_Initialize (&game_mode, XPAR_GAME_MODE_DEVICE_ID);

	XGpio_DiscreteWrite (&white_color, 1, white_color_val);
	XGpio_DiscreteWrite (&black_color, 1, black_color_val);
	XGpio_DiscreteWrite (&white_count, 1, white_count_val);
	XGpio_DiscreteWrite (&black_count, 1, black_count_val);
	XGpio_DiscreteWrite (&calib, 1, calib_val);

	// Initialize UART.
	uartInit(XPAR_RS232_UART_1_BASEADDR);

	clearScreen ();

	state = MAIN_MENU;

	while(1)
	{
		clearUartScreen ();
		
		switch (state) {
			// Display the main menu.
		case MAIN_MENU:
			mainMenu ();
			break;
			// Play a song in xylophone hero.
		case GAME_MODE:
			gameMode ();
			break;
			// Display credits.
		case CREDITS:
			credits ();
			break;
			// Calibrate.
		case CALIBRATE:
			calibrate ();
			break;
		default: break;
		}
	}

	return 0;
}



/*******************************************************
*
* Menu functions.
*
*******************************************************/


/* Display the main menu. */
static void mainMenu ()
{
	clearUartScreen ();
	printSubtitle ("@@@ WELCOME TO XYLOPHONE HERO!!! @@@", 0x0000FFFF, 0x00000000, 10, 10);
	printSubtitle ("1: GAME MODE", 0x0000FFFF, 0x00000000, 10, 26);
	printSubtitle ("2: CREDITS", 0x0000FFFF, 0x00000000, 10, 42);
	printSubtitle ("3: CALIBRATE", 0x0000FFFF, 0x00000000, 10, 58);

	while (1)
	{
		char c = uartScan ();
		switch (c) {
		case '1':
			state = GAME_MODE;
			return;
		case '2':
			state = CREDITS;
			return;
		case '3':
			state = CALIBRATE;
			return;
		default:
			break;
		}
	}
}

/* Display credits. */
static void credits ()
{
	clearScreen ();
	printSubtitle ("XYLOPHONE HERO PRESENTED TO YOU BY", 0x0000FFFF, 0x00000000, 10, 10);
	printSubtitle ("@@@ BENJAMIN XIAO @@@", 0x0000FFFF, 0x00000000, 10, 26);
	printSubtitle ("@@@ CHEN GUO @@@", 0x0000FFFF, 0x00000000, 10, 42);
	printSubtitle ("@@@ JESSICA WANG @@@", 0x0000FFFF, 0x00000000, 10, 58);
	printSubtitle ("PRESS ANY KEY TO RETURN TO MAIN MENU", 0x0000FFFF, 0x00000000, 10, 74);

	XGpio_DiscreteWrite(&game_mode, 1, 1);
	while (1)
	{
		//sendFrame ();
		if (uartScan () != 0)
		{
			state = MAIN_MENU;
			return;
		}
	}
	XGpio_DiscreteWrite(&game_mode, 1, 0);
}



/*******************************************************
*
* Game functions.
*
*******************************************************/


/* Play Xylophone Hero. */
static void gameMode ()
{
	int x;
	int y;
	int addr;

	print ("Press Q to quit.\r\n");

	while (1)
	{
		for (y = 400; y > 100; y--)
		{
			addr = 1024 * y;
			//for (x = 0; x < 640; x++)
			//pDisplay_data[addr + x] = pDisplay_data[addr + x - 5120];
		}

		int i;
		for (i = 0; i < 8; i++)
		{
			int random = rand() % 20;
			int color;
			if (random == 3)
			{
				printLetter ('@', 0x00FF0000, 0X00000000, 120 + 50 * i, 101);
			}
		}
		
		char c = uartScan ();
		if (c == 'Q' || c == 'q')
		{
			state = MAIN_MENU;
			return;
		}
	}
}



/*******************************************************
*
* Calibration functions.
*
*******************************************************/


/* Calibrate a single value to send to FGPA. */
static void calibrateValue (char *c, XGpio *port, Xuint32 *value)
{
	char buf[20];

	calib_top:
	clearScreen ();
	clearUartScreen ();
	printSubtitle (c, 0x0000FFFF, 0, 10, 10);
	printSubtitle ("Current value: ", 0x0000FFFF, 0, 10, 26);
	itoa (*value, buf);
	printSubtitle (buf, 0x0000FFFF, 0, 10, 42);
	printSubtitle ("+: INCREASE VALUE", 0x0000FFFF, 0, 10, 58);
	printSubtitle ("-: DECREASE VALUE", 0x0000FFFF, 0, 10, 74);
	printSubtitle ("Q: BACK", 0x0000FFFF, 0, 10, 90);

	while (1)
	{
		char c = uartScan ();
		switch (c) {
		case '=':
		case '+':
			*value += 1;
			XGpio_DiscreteWrite (port, 1, *value);
			goto calib_top;
			
		case '-': 
			*value -= 1;
			XGpio_DiscreteWrite (port, 1, *value);
			goto calib_top;
			
		case 'q':
		case 'Q':
			return;      

		default: break;
		}
	}
}

/* Detection collision regions on the xylophone sheet. */
static void calibrateSheet ()
{
	printSubtitle ("R: RE-CALIBRATE SHEET SECTIONS", 0x0000FFFF, 0, 10, 10);
	printSubtitle ("W: CONTINUE TO BALL CALIBRATION", 0x0000FFFF, 0, 10, 28);
	XGpio_DiscreteWrite (&calib, 1, 2);
	XGpio_DiscreteWrite (&calib, 1, 1);

	while (1)
	{
		char c = uartScan ();
		if (c == 'r' || c == 'R')
		{
			XGpio_DiscreteWrite (&calib, 1, 2);
			XGpio_DiscreteWrite (&calib, 1, 1);
		}
		else if (c == 'w' || c == 'W')
		return;
	}

}

/* Calibrate for size of the ball. */
static void calibrateBall ()
{
	printSubtitle ("PLACE THE BALL AT THE FRONT OF THE SHEET AND PRESS W", 0x0000FFFF, 0, 10, 90);
	XGpio_DiscreteWrite (&calib, 1, 3);
	while (1)
	{
		char c = uartScan ();
		if (c == 'W' || c == 'w')
		break;
	}
	printSubtitle ("PLACE THE BALL AT THE BACK OF THE SHEET AND PRESS Q", 0x0000FFFF, 0, 10, 90);
	XGpio_DiscreteWrite (&calib, 1, 4);
	while (1)
	{
		char c = uartScan ();
		if (c == 'q' || c == 'Q')
		break;
	}
	XGpio_DiscreteWrite (&calib, 1, 5);
	XGpio_DiscreteWrite (&calib, 1, 1);
}

static void calibrate ()
{
	XGpio_DiscreteWrite (&calib, 1, 1);
	printSubtitle ("CALIBRATION", 0x0000FFFF, 0x00000000, 10, 10);
	printSubtitle ("1: WHITE COLOR", 0x0000FFFF, 0, 10, 26);
	printSubtitle ("2: BLACK COLOR", 0x0000FFFF, 0, 10, 42);
	printSubtitle ("3: WHITE COUNT", 0x0000FFFF, 0, 10, 58);
	printSubtitle ("4: BLACK COUNT", 0x0000FFFF, 0, 10, 74);
	printSubtitle ("5: CALIBRATE", 0x0000FFFF, 0, 10, 90);
	printSubtitle ("Q: MAIN MENU", 0x0000FFFF, 0, 10, 106);

	while (1)
	{
		char c = uartScan ();
		switch (c) {
		case '1':
			calibrateValue ("CALIBRATE WHITE COLOR", &white_color, &white_color_val);
			return;
		case '2':
			calibrateValue ("CALIBRATE BLACK COLOR", &black_color, &black_color_val);
			return;
		case '3':
			calibrateValue ("CALIBRATE WHITE COUNT", &white_count, &white_count_val);
			return;
		case '4':
			calibrateValue ("CALIBRATE BLACK COUNT", &black_count, &black_count_val);
			return;
		case '5':
			calibrateSheet ();
			calibrateBall ();
			return;
			
		case 'q':
		case 'Q':
			state = MAIN_MENU;
			XGpio_DiscreteWrite (&calib, 1, 0);
			return;
		default: break;
		}
	}
}



/*******************************************************
*
* Helper functions.
*
*******************************************************/


/* Print a subtitle passed in as a C-string. */
static void printSubtitle (char *c, unsigned int color, unsigned int background, int pos_x, int pos_y)
{
	while (*c != '\0')
	{
		printLetter (*c, color, background, pos_x, pos_y);
		uartWrite(*c);
		pos_x += 10;
		c++;
	}
	uartWrite('\r');
	uartWrite('\n');
}

/* Print a single letter of the subtitle. */
static void printLetter(char c, unsigned int color, unsigned int background, int pos_x, int pos_y)
{
	int num;
	if (c <= '9')
	num = c - ' ';
	else
	num = c - '?' + 26;

	char *char_array = characters[num];

	int x;
	int y;
	for (y = 0; y < 12; y++)
	{
		int shift = 7;
		for (x = 0; x < 8; x++)
		{
			//pDisplay_data[y][x] = ((char_array[y] >> shift & 1) == 0)? background : color;
			shift--;
		}
	}
}

/* Send a frame to the FPGA. */
static void sendFrame() {
	//uartWrite ('a');
	while (!XGpio_DiscreteRead(&frame_start, 1)) {
		// Do nothing while waiting for FPGA to get ready
	}
	//uartWrite ('b');

	int x;
	int y;

	for (y = 0; y < DISP_H; y++)
	{
		int pixel = 1;
		if (y < 240)
		pixel = 0;
		for (x = 0; x < DISP_W; x++)
		{
			//int buf_val = frame_buf[x/32][y/2];
			//int pixel = (buf_val >> (x % 32)) & 1;
			// Wait for clock high.
			while (!XGpio_DiscreteRead(&clk_27, 1));
			XGpio_DiscreteWrite(&BW, 1, pixel);

			// Wait for clock low.
			while (XGpio_DiscreteRead(&clk_27, 1));
		}
		//uartWrite ('c');
	}
}

/* Draw a beautiful 5x5 white box. */
static void drawBox(int pos_x, int pos_y, int color)
{
	int x, y;
	for (y = pos_y; y < pos_y + 5; y++)
	{
		for (x = pos_x; x < pos_x + 5; x++)
		;//pDisplay_data[y][x] = color;
	}
}

/* Make the entire screen black. */
static void clearScreen ()
{
	unsigned int x;
	unsigned int y;
	for (y = 0; y < BUF_H; y++)
	for (x = 0; x < BUF_W; x++)
	frame_buf[x][y] = 0;
}

/* Convert a 4 digit number to a C-string. */
static void itoa (int num, char *c)
{
	char buf[25];
	int i = 0;
	int j = 0;
	do
	{
		int new_num = num / 10;
		int digit = num - 10 * new_num;
		buf[i++] = digit + '0';
		num = new_num;    
	}
	while (num > 0);

	// Copy buf to input buffer.
	while (i > 0)
	c[j++] = buf[--i];
	c[j] = '\0';
}

void configDecoder(struct VideoModule *decoder, int config_cnt ) 
{
  Xuint16 send_cnt, i;
  Xuint8 send_data[2] = {0};
  Xuint8 success = 1;
  send_cnt = 2;
  print("  Configuring Decoder...\t");
  for( i = 0; i < config_cnt; i++ )
   {

    XI2c_mWriteReg(XPAR_I2C_BASEADDR, GPO_REG_OFFSET, GPO_RESET_IIC);
    XI2c_mWriteReg(XPAR_I2C_BASEADDR, GPO_REG_OFFSET, GPO_RESETS_OFF);
    send_data[0] = decoder[i].addr;

    send_data[1] = decoder[i].config_val;

    send_cnt = XI2c_Send(XPAR_I2C_BASEADDR, DECODER_ADDR, send_data, 2);

    if( send_cnt != 2 ) 
	 {
      xil_printf("Error writing to address %02x\r\n", decoder[i].addr);
      success = 0;
      break;
     }
   }

  if( success )
    print("SUCCESS!\r\n");

} // end configDecoder()

void Reset_xup_decoder(void)
{
int send_cnt = 0;
int wait_delay = 500000;
    XI2c_mWriteReg(XPAR_I2C_BASEADDR, GPO_REG_OFFSET, GPO_RESET_DECODER);  // reset  to vid decoder
	while(wait_delay)
   {
    wait_delay = wait_delay -1;
	}
    XI2c_mWriteReg(XPAR_I2C_BASEADDR, GPO_REG_OFFSET, GPO_RESETS_OFF);  // set resets de - asserted
	wait_delay = 5000000;
   while(wait_delay)
   {
    wait_delay = wait_delay -1;
	}
   return;
}  // end Reset_xup_decoder

unsigned char get_hex_byte()
{
  unsigned char s ,x, pass;
  pass = 0;
  s = 0;
  x = 0;
    while( s != 13)
    {
    s = uartRead();
	xil_printf("%c",s); //echo back 
	if((s < '0' ||  s >'f')  && s != 13){
	  print(" invalid entry start over \n\r");
	  x = 0;
	  }
	if( s == 13){
	  break;
	  }
	 else{
	  if(pass != 0){
	   x= x*16;
	   }
	  if(s > 47 && s < 58){
	  s = ( s - '0');
	  x = x + s;
	  }
	  else if( s == 'a'){
	   x = x + 10;
	   }
	   else if( s == 'b'){
	   x = x + 11;
	   }
	   else if( s == 'c'){
	   x = x + 12;
	   }
	   else if( s == 'd'){
	   x = x + 13;
	   }
	   else if( s == 'e'){
	   x = x + 14;
	   }
	   else if( s == 'f'){
	   x = x + 15;
	   }
      pass++;
	  }
	}

	return x;
}
void edit_i2c_reg(void)
{
  Xuint8 send_data[2] = {0};
  int send_cnt = 0;
  char s = 0;
  
    XI2c_mWriteReg(XPAR_I2C_BASEADDR, GPO_REG_OFFSET, GPO_RESET_IIC);
    XI2c_mWriteReg(XPAR_I2C_BASEADDR, GPO_REG_OFFSET, GPO_RESETS_OFF);
	print("\r\nEdit I2C Register Settings Mode.\r\n");
   do {
		print("\r\nEnter I2C Hex Register Address  ");
		send_data[0] = get_hex_byte();
		print("\r\nEnter I2C Hex Register Data     ");
		send_data[1] = get_hex_byte();
		send_cnt = XI2c_Send(XPAR_I2C_BASEADDR, DECODER_ADDR, send_data, 2);
	    if( send_cnt != 2 ) 
		  {
	      xil_printf("Error writing to address %02x\r\n", send_data[0]);
	      }
	    print("\r\nWriting New Reg Value.\r\n\r\nType c to continue edits, Or  q to quit. ");
		s =uartRead();
	} while( s != 'q' );
  print("\r\n\r\n");
  return;
}
