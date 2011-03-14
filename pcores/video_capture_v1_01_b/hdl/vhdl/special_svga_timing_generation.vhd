----------------------------------------------------------------------------------------------
--
--      Design name        : SPECIAL_SVGA_TIMING_GENERATION
--
----------------------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY SPECIAL_SVGA_TIMING_GENERATION IS
   PORT (
      pixel_clock             : IN std_logic;   
      reset                   : IN std_logic;   
      h_synch_delay           : OUT std_logic;   
      v_synch_delay           : OUT std_logic;   
      comp_synch              : OUT std_logic;   
      blank                   : OUT std_logic;   
      char_line_count         : OUT std_logic_vector(2 DOWNTO 0);   
      char_address            : OUT std_logic_vector(13 DOWNTO 0);   
      char_pixel              : OUT std_logic_vector(2 DOWNTO 0);   
      pixel_count             : OUT std_logic_vector(10 DOWNTO 0);   
	  row_count				  : OUT std_logic_vector(9 DOWNTO 0));   
END SPECIAL_SVGA_TIMING_GENERATION;

ARCHITECTURE behavioral OF SPECIAL_SVGA_TIMING_GENERATION IS


   SIGNAL line_count               :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL h_synch                  :  std_logic;   
   SIGNAL v_synch                  :  std_logic;   
   SIGNAL h_synch_delay0           :  std_logic;   
   SIGNAL v_synch_delay0           :  std_logic;   
   SIGNAL h_c_synch                :  std_logic;   
   SIGNAL v_c_synch                :  std_logic;   
   SIGNAL h_blank                  :  std_logic;   
   SIGNAL v_blank                  :  std_logic;   
   SIGNAL char_count               :  std_logic_vector(16 DOWNTO 0);   
   SIGNAL line_start_address       :  std_logic_vector(16 DOWNTO 0);   
   SIGNAL reset_char_count         :  std_logic;   
   SIGNAL hold_char_count          :  std_logic;   
   SIGNAL char_line_count_tmp5    :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL char_pixel_tmp7         :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL pixel_count_tmp8        :  std_logic_vector(10 DOWNTO 0);
   SIGNAL temp					   :  std_logic_vector(9 DOWNTO 0);

BEGIN
   char_line_count <= char_line_count_tmp5;
   char_pixel <= char_pixel_tmp7;
   pixel_count <= pixel_count_tmp8;
   row_count <= line_count;

-- CREATE THE HORIZONTAL LINE PIXEL COUNTER   
   PROCESS (pixel_clock, reset)
   BEGIN
      IF (reset = '1') THEN
         pixel_count_tmp8 <= "00000000000";    
      ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
         IF (pixel_count_tmp8 = (conv_std_logic_vector((858-1),11))) THEN
            pixel_count_tmp8 <= "00000000000";    
         ELSE
            pixel_count_tmp8 <= pixel_count_tmp8 + "00000000001";    
         END IF;
      END IF;
   END PROCESS;

-- CREATE THE HORIZONTAL SYNCH PULSE
   PROCESS (pixel_clock, reset)
   BEGIN
      IF (reset = '1') THEN
         h_synch <= '0';    
      ELSIF (pixel_clock'EVENT AND pixel_clock = '1')	THEN
         IF (pixel_count_tmp8 = conv_std_logic_vector((720 + 7 - 1), 11)) THEN
            h_synch <= '1';    
         ELSE
            IF (pixel_count_tmp8 = conv_std_logic_vector((858 - 69 - 1), 11)) THEN
               h_synch <= '0';    
            END IF;
         END IF;
      END IF;
   END PROCESS;

-- CREATE THE VERTICAL FRAME LINE COUNTER
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       line_count <= conv_std_logic_vector((525 - 33), 10);    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF ((line_count = conv_std_logic_vector((525 - 1), 10)) AND (pixel_count_tmp8 = conv_std_logic_vector((858 - 1), 11))) THEN
          line_count <= "0000000000";    
       ELSE
          IF (pixel_count_tmp8 = conv_std_logic_vector((858 - 1), 11)) THEN
             line_count <= line_count + "0000000001";    
          END IF;
       END IF;
    END IF;
 END PROCESS;

-- CREATE THE VERTICAL SYNCH PULSE
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       v_synch <= '0';    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF (line_count = conv_std_logic_vector((487 + 4 - 1), 10) AND (pixel_count_tmp8 = conv_std_logic_vector(858 - 1, 11))) THEN
          v_synch <= '1';    
       ELSE
          IF ((line_count = conv_std_logic_vector((525 - 30 - 1), 10)) AND (pixel_count_tmp8 = conv_std_logic_vector((858 - 1), 11))) THEN
             v_synch <= '0';    
          END IF;
       END IF;
    END IF;
 END PROCESS;

-- ADD TWO PIPELINE DELAYS TO THE SYNCHs COMPENSATE FOR THE DAC PIPELINE DELAY
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       h_synch_delay0 <= '0';    
       v_synch_delay0 <= '0';    
       h_synch_delay <= '0';    
       v_synch_delay <= '0';    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       h_synch_delay0 <= h_synch;    
       v_synch_delay0 <= v_synch;    
       h_synch_delay <= h_synch_delay0;    
       v_synch_delay <= v_synch_delay0;    
    END IF;
 END PROCESS;

-- CREATE THE HORIZONTAL BLANKING SIGNAL
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       h_blank <= '0';    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF (pixel_count_tmp8 = conv_std_logic_vector((720 - 2), 11)) THEN
          h_blank <= '1';    
       ELSE
          IF (pixel_count_tmp8 = conv_std_logic_vector((858 - 2), 11)) THEN
             h_blank <= '0';    
          END IF;
       END IF;
    END IF;
 END PROCESS;

-- CREATE THE VERTICAL BLANKING SIGNAL
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       v_blank <= '1';    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF (line_count = conv_std_logic_vector((487 - 1), 10) AND (pixel_count_tmp8 = conv_std_logic_vector(858 - 2, 11))) THEN
          v_blank <= '1';    
       ELSE
          IF ((line_count = conv_std_logic_vector((525 - 1), 10)) AND (pixel_count_tmp8 = conv_std_logic_vector((858 - 2), 11))) THEN
             v_blank <= '0';    
          END IF;
       END IF;
    END IF;
 END PROCESS;

-- CREATE THE COMPOSITE BANKING SIGNAL
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       blank <= '0';    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF ((h_blank OR v_blank) = '1') THEN
          blank <= '1';    
       ELSE
          blank <= '0';    
       END IF;
    END IF;
 END PROCESS;

-- CREATE THE HORIZONTAL COMPONENT OF COMP SYNCH
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       h_c_synch <= '0';    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF (pixel_count_tmp8 = conv_std_logic_vector((720 + 7 - 2), 11)) THEN
          h_c_synch <= '1';    
       ELSE
          IF (pixel_count_tmp8 = conv_std_logic_vector((858 - 69 - 2), 11)) THEN
             h_c_synch <= '0';    
          END IF;
       END IF;
    END IF;
 END PROCESS;

-- CREATE THE HORIZONTAL COMPONENT OF COMP SYNCH
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       v_c_synch <= '0';    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF (line_count = conv_std_logic_vector((487 + 4 - 1), 10) AND (pixel_count_tmp8 = conv_std_logic_vector(858 - 2, 11))) THEN
          v_c_synch <= '1';    
       ELSE
          IF ((line_count = conv_std_logic_vector((525 - 30 - 1), 10)) AND (pixel_count_tmp8 = conv_std_logic_vector((858 - 2), 11))) THEN
             v_c_synch <= '0';    
          END IF;
       END IF;
    END IF;
 END PROCESS;

-- CREATE THE COMPOSITE SYNCH SIGNAL
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       comp_synch <= '0';    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       comp_synch <= v_c_synch XOR h_c_synch;    
    END IF;
 END PROCESS;

-- CREATE THE VERTICAL FRAME LINE COUNTER
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       char_line_count_tmp5 <= "000";    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF ((line_count = conv_std_logic_vector((525 - 1), 10)) AND (pixel_count_tmp8 = conv_std_logic_vector((858 - 1) - 4, 11))) THEN
          char_line_count_tmp5 <= "000";    
	     ELSE
         IF (pixel_count_tmp8 = conv_std_logic_vector((858 - 1) - 4, 11)) THEN
             temp <= line_count + "0000000001";--(2 DOWNTO 0);
			 char_line_count_tmp5 <= temp(2 DOWNTO 0);
				 -- might cause a problem. Only the two LSB's are needed.
        END IF;
      END IF;
    END IF;
 END PROCESS;

 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       char_count <= "00000000000000000";
	   char_address(13 DOWNTO 0) <= char_count(16 DOWNTO 3);
       line_start_address <= "00000000000000000";    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF (reset_char_count = '1') THEN
          char_count <= "00000000000000000";    
          line_start_address <= "00000000000000000";    
       ELSE
          IF (NOT hold_char_count = '1') THEN
             char_count <= char_count + "00000000000000001";    
             char_address(13 DOWNTO 0) <= char_count(16 DOWNTO 3);
             line_start_address <= line_start_address;    
          ELSE
             IF (char_line_count_tmp5 = "111") THEN
                char_count <= char_count;    
               line_start_address <= char_count;    
            ELSE
                char_count <= line_start_address;
				char_address(13 DOWNTO 0) <= char_count(16 DOWNTO 3);    
                line_start_address <= line_start_address;    
             END IF;
          END IF;
       END IF;
    END IF;
 END PROCESS;

-- char_pixel defines the pixel within the character line
 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       char_pixel_tmp7 <= "101";    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF (pixel_count_tmp8 = conv_std_logic_vector(((858 - 1) - 4), 11)) THEN
          char_pixel_tmp7 <= "101";    
       ELSE
          char_pixel_tmp7 <= char_pixel_tmp7 + "001";    
       END IF;
    END IF;
 END PROCESS;

-- CREATE THE CONTROL SIGNALS FOR THE CHARACTER ADDRESS COUNTER
-- 	The HOLD and RESET signals are advanced from the beginning and end
--	of HBI and VBI to compensate for the internal character generation
--	pipeline.

 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       reset_char_count <= '0';    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF (line_count = conv_std_logic_vector((487 - 1), 10) AND pixel_count_tmp8 = conv_std_logic_vector(((720 - 1) - 4), 11)) THEN
          reset_char_count <= '1';    
       ELSE
          IF (line_count = conv_std_logic_vector((525 - 1), 10) AND pixel_count_tmp8 = conv_std_logic_vector(((858 - 1) - 4), 11)) THEN
             reset_char_count <= '0';    
          END IF;
       END IF;
    END IF;
 END PROCESS;

 PROCESS (pixel_clock, reset)
 BEGIN
    IF (reset = '1') THEN
       hold_char_count <= '0';    
    ELSIF (pixel_clock'EVENT AND pixel_clock = '1') THEN
       IF (pixel_count_tmp8 = conv_std_logic_vector(((720 - 1) - 4), 11)) THEN
          hold_char_count <= '1';    
       ELSE
          IF (pixel_count_tmp8 = conv_std_logic_vector(((858 - 1) - 4), 11)) THEN
             hold_char_count <= '0';    
          END IF;
       END IF;
    END IF;
 END PROCESS;

END behavioral;