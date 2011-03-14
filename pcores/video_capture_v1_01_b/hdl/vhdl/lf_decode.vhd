----------------------------------------------------------------------------------------------
--
--      Design name        : lf_decode
--
-- DETAILED DESCRIPTION:
--
--
--
--The reserved 8 bit values of 00h and FFh (consumer format) or 10 bits
--values of 000 and 3FFh (studio format) are used to signal what is known
--as a TRS - Timing Reference Symbol.  The TRS consists of the sequence FF
--
--
--a special word XY that
--resides in either the 8 bit consumer field or the upper 8 bits of the 10
--bit studio field (the 2 lsbs undefined). 
--
--This word, when decoded, combined with various counts, such as line 
--count, can completely specify NTSC or PAL timing.
--
--This module decodes this information and supplies timing control signals
--to the video controller, frame buffer, and DAC.
--
--The video standard ITU-R BT.656, defines the following:
--
--   1. color space
--   2. the number of samples
--   3. where the samples are located in an image, also known
--      as the sampling format
--   4. how the pixels are stored in the frame buffer. 
--
--The color space definition is known as YCbCr. YCbCr is a scaled and
--offset version of the YUV color space. The 4:2:2 format has for every
--horizontal Y (Luminance) sample a single Chrominance sample (either 
--Cr or Cb). Cb and Cr are sampled less because the eye is more sensitive 
--to luminance than chrominance, so storing pixels this way is more frame 
--buffer efficient. 
--
--Each sample is 8 bits (for consumer applications)and 10 bits for 
--commercial studio quality. The Virtex II video board supports 10 bits
--where the two extra bits are considered fractional.  The range of
--values for each are:
--
--   Y  = 16 to 235 or 040h to 3ACh (i.e. 220 values)
--   Cr = 16 to 240 or 040h to 3C0h (i.e. 225 values)
--   Cb = 16 to 240 or 040h to 3C0h (i.e. 225 values)
--   note: for Cr and Cb 128 is "zero"
--
--The video data words are conveyed as 27 million, 10 bit words, in the
--following order: 
--
--             1    2   3    4   5    6   7
--             Cb0, Y0, Cr0, Y1, Cb2, Y2, Cr2
--
--Field and frame timing is actually imbedded in the data stream by
--reserving the values of 00h and FFh for field/line ID. The pattern FF 00
--00 is used as a field ID and appears in every line. If a field ID is
--detected then the next 8 bit pixel has different meaning depending on
--it's value. I'll call the value XY. The 8 bit data stream is sampled on
--the rising edge of the 27 MHz clock.
--
--The terms SAV and EAV mean "start of active video" and "end of active
--video", repectively. SAV is marked with a field ID followed by bit 4 in
--the XY word low. Active pixels then follow. EAV is also marked with a
--field ID where bit 4 in the XY word is high. Horizontal blanking
--follows.
--
--Field number and Field blanking are also conveyed by XY, following a
--field ID. The "F bit" or bit position 6 and the "V bit" or bit position
--5 are decoded as follows:
--
--F = 0, denotes field 1, odd
--F = 1, denotes field 2, even
--V = 0, denotes no field blanking
--V = 1, denotes field blanking
--
--So a simple statement of this modules function is, for each line, find
--the field ID pattern FF 00 00 XY then look at XY. XY will tell us what
--field we are in, whether or not field blanking is active, and if XY
--denotes a SAV, then we know we are at pixel 0.  Deciding which format
--is being displayed is done by counting SAVs between field blanking.
--
--To identify the format as NTSC (485 active lines or 525 total lines) or
--as PAL (576 active lines or 625 total) you can look for the V bit to
--signal active lines are starting (V was a 1, then transitioned to a 0)
--and count SAVs until the V bit goes high or active lines have stopped.
--This number is compared to the format line counts and NTSC or PAL flag
--is set.
--
----------------------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY lf_decode IS
   PORT (
      rst                     : IN std_logic;   
      clk                     : IN std_logic;   
      YCrCb_in                : IN std_logic_vector(9 DOWNTO 0);   
      YCrCb_out               : OUT std_logic_vector(9 DOWNTO 0);   
      NTSC_out                : OUT std_logic;   
      Fo                      : OUT std_logic;   
      Vo                      : OUT std_logic;   
      Ho                      : OUT std_logic);   
END lf_decode;

ARCHITECTURE behavioral OF lf_decode IS

   SIGNAL YCrCb_rg1                :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL YCrCb_rg2                :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL YCrCb_rg3                :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL YCrCb_rg4                :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL YCrCb_rg5                :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL TRS                      :  std_logic;   
   SIGNAL H_rg                     :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL V_rising                 :  std_logic;   
   SIGNAL V_falling                :  std_logic;   
   SIGNAL H_rising                 :  std_logic;   
   SIGNAL format_count             :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL format_count_max         :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL Fo_tmp3                 :  std_logic;   
   SIGNAL Vo_tmp4                 :  std_logic;   

BEGIN

   YCrCb_out <= YCrCb_rg5;
   Fo <= Fo_tmp3;
   Vo <= Vo_tmp4;

   TRS <= ((NOT (YCrCb_rg2(9) OR YCrCb_rg2(8) OR YCrCb_rg2(7) OR YCrCb_rg2(6) OR YCrCb_rg2(5) OR YCrCb_rg2(4) OR YCrCb_rg2(3) OR YCrCb_rg2(2)))
		 AND (NOT (YCrCb_rg3(9) OR YCrCb_rg3(8) OR YCrCb_rg3(7) OR YCrCb_rg3(6) OR YCrCb_rg3(5) OR YCrCb_rg3(4) OR YCrCb_rg3(3) OR YCrCb_rg3(2)))
		 AND (YCrCb_rg4(9) OR YCrCb_rg4(8) OR YCrCb_rg4(7) OR YCrCb_rg4(6) OR YCrCb_rg4(5) OR YCrCb_rg4(4) OR YCrCb_rg4(3) OR YCrCb_rg4(2)));

    PROCESS
    BEGIN
       WAIT UNTIL (clk'EVENT AND clk = '1');
       IF (rst = '1') THEN
    		YCrCb_rg1 <= "0000000000";
    		YCrCb_rg2 <= "0000000000";
    		YCrCb_rg3 <= "0000000000";
    		YCrCb_rg4 <= "0000000000";
		    YCrCb_rg5 <= "0000000000";
       ELSE
	        YCrCb_rg1 <= YCrCb_in;    -- 1 clock delay
		    YCrCb_rg2 <= YCrCb_rg1;   -- 2 clock delay
            YCrCb_rg3 <= YCrCb_rg2;   -- 3 clock delay
    	    YCrCb_rg4 <= YCrCb_rg3;   -- 4 clock delay
    	    YCrCb_rg5 <= YCrCb_rg4;   -- 5 clock delay
       END IF;
    END PROCESS;

    PROCESS
    BEGIN
       WAIT UNTIL (clk'EVENT AND clk = '1');
       IF (rst = '1') THEN
          Fo_tmp3 <= '0';    
          Vo_tmp4 <= '0';
          H_rg <= "00000";    
       ELSIF (TRS = '1') THEN
             Fo_tmp3 <= YCrCb_rg1(8);    
             Vo_tmp4 <= YCrCb_rg1(7);    
             H_rg(4 DOWNTO 0) <= H_rg(4 DOWNTO 1) & YCrCb_rg1(6);    
          ELSE
             H_rg(4 DOWNTO 0) <= H_rg(3 DOWNTO 0) & H_rg(0);    
          END IF;
    END PROCESS;

    Ho <= H_rg(0) OR H_rg(4) ;
    H_rising <= H_rg(0) AND NOT H_rg(1) ;
    V_rising <= (TRS AND YCrCb_rg1(7)) AND NOT Vo_tmp4 ;
    V_falling <= (TRS AND NOT YCrCb_rg1(7)) AND Vo_tmp4 ;
   
      
    PROCESS	(clk, rst, V_rising, H_rising, V_falling)
    BEGIN
       IF (rst = '1') THEN
          format_count <= "00000";    
          format_count_max <= "10011";    
       ELSIF (clk'EVENT AND clk = '1') THEN
          IF ((V_rising AND H_rising) = '1') THEN
             format_count <= "00001";    
             format_count_max <= format_count_max;    
          ELSE
             IF ((V_falling AND H_rising) = '1') THEN
                format_count <= "00001";    
                format_count_max <= format_count;    
             ELSE
                IF ((NOT V_rising AND H_rising) = '1') THEN
						 format_count <= format_count + "00001";
                   format_count_max <= format_count_max;    
                ELSE
                   format_count <= format_count;    
                   format_count_max <= format_count_max;    
                END IF;
             END IF;
          END IF;
       END IF;
    END PROCESS;
	 
	NTSC_out <= (format_count_max(4) AND NOT(format_count_max(3)) AND NOT(format_count_max(2)) AND format_count_max(1) AND format_count_max(0)); --"10011"
 
END behavioral;