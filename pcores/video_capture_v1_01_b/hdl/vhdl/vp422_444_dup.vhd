----------------------------------------------------------------------------------------------
--
--      Design name        : vp422_444_dup
--
--BRIEF DESCRIPTION
--
--The process of 4:2:2 to 4:4:4 is simply creating the missing Cr and Cb
--components. This version accomplishes this task by merely duplicating
--the Cr and Cb information.
--
--DETAILED DESCRIPTION
--
--The video standard ITU-R BT.601 was introduced as the need for
--transporting digital component video between countries and standards
--increased. The analog component R'G'B' can be sampled in a very regular
--way and converted from 4:4:4 to the digital 4:2:2 format, essentially
--cutting in half the number of different components, Cr and Cb. 
--
--The digital data is efficiently stored or transmitted to a destination
--that reverses the process, i.e. converts back to 4:4:4 format, and
--produces analog YUV or R'G'B' for display.
--
----------------------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY vp422_444_dup IS
   PORT (
      rst                     : IN std_logic;   
      clk                     : IN std_logic;   
      ycrcb_in                : IN std_logic_vector(9 DOWNTO 0);   
      ntsc_in                 : IN std_logic;   
      fi                      : IN std_logic;   
      vi                      : IN std_logic;   
      hi                      : IN std_logic;   
      ceo                     : OUT std_logic;   
      ntsc_out_o              : OUT std_logic;   
      fo                      : OUT std_logic;   
      vo                      : OUT std_logic;   
      ho                      : OUT std_logic;   
      y_out                   : OUT std_logic_vector(9 DOWNTO 0);   
      cr_out                  : OUT std_logic_vector(9 DOWNTO 0);   
      cb_out                  : OUT std_logic_vector(9 DOWNTO 0));   
END vp422_444_dup;

ARCHITECTURE behavioral OF vp422_444_dup IS


   SIGNAL state_cnt                :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL ycrcb_in_reg             :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL pipe_fo                  :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL pipe_ntsc                :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL pipe_vo                  :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL pipe_ho                  :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL Y_rg1                    :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Y_rg2                    :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Y_rg3                    :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Y_rg4                    :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL chroma_red_rg1           :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL chroma_red_rg2           :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL chroma_red_rg3           :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL chroma_red_rg4           :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL chroma_blue_rg1          :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL chroma_blue_rg2          :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL chroma_blue_rg3          :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL chroma_blue_rg4          :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL chroma_blue_rg5          :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL h_falling                :  std_logic;   
   SIGNAL blanking                 :  std_logic;   
   SIGNAL vi_reg                   :  std_logic;   
   SIGNAL hi_reg                   :  std_logic;   
   SIGNAL ntsc_reg                 :  std_logic;   
   SIGNAL fi_reg                   :  std_logic;   
   SIGNAL ena_luma_reg             :  std_logic;   
   SIGNAL ena_chroma_red_reg       :  std_logic;   
   SIGNAL ena_chroma_blue_reg      :  std_logic;   

BEGIN
   h_falling <= hi_reg AND NOT hi ;
   ceo <= (NOT pipe_ho(0) AND NOT pipe_vo(0)) AND ena_luma_reg ;
   ena_luma_reg <= (state_cnt(0) AND NOT state_cnt(1)) OR (state_cnt(1) AND state_cnt(0)) ;
   ena_chroma_blue_reg <= NOT state_cnt(0) AND NOT state_cnt(1) ;
   ena_chroma_red_reg <= NOT state_cnt(0) AND state_cnt(1) ;
   y_out(9 DOWNTO 0) <= Y_rg4(9 DOWNTO 0) ;
   cr_out(9 DOWNTO 0) <= chroma_red_rg3(9 DOWNTO 0) ;
   cb_out(9 DOWNTO 0) <= chroma_blue_rg5(9 DOWNTO 0) ;
   vo <= pipe_vo(0) ;
   fo <= pipe_fo(0) ;
   ho <= pipe_ho(0) ;
   ntsc_out_o <= pipe_ntsc(0) ;

   -- create a counter to keep track of the data stream contents
   PROCESS
   BEGIN
      WAIT UNTIL (clk'EVENT AND clk = '1');
      IF ((rst OR h_falling) = '1') THEN
        state_cnt <= "00";    
      ELSE		
         state_cnt <= state_cnt + "01";    
      END IF;
   END PROCESS;
      
	-- register the inputs
   PROCESS
   BEGIN
      WAIT UNTIL (clk'EVENT AND clk = '1');
      IF (rst = '1') THEN
         vi_reg <= '0';    
         hi_reg <= '0';    
         fi_reg <= '0';    
         ntsc_reg <= '0';    
         ycrcb_in_reg <= "0000000000";    
      ELSE
         vi_reg <= vi;    
         hi_reg <= hi;    
         fi_reg <= fi;    
         ntsc_reg <= ntsc_in;    
         ycrcb_in_reg(9 DOWNTO 0) <= ycrcb_in(9 DOWNTO 0);    
      END IF;
   END PROCESS;

   -- pipe line delay F, V, H, NTSC to match delay of 444 dup
   PROCESS
   BEGIN
      WAIT UNTIL (clk'EVENT AND clk = '1');
      pipe_vo(4) <= vi_reg;    
      pipe_vo(3 DOWNTO 0) <= pipe_vo(4 DOWNTO 1);    
      pipe_fo(4) <= fi_reg;    
      pipe_fo(3 DOWNTO 0) <= pipe_fo(4 DOWNTO 1);    
      pipe_ho(4) <= hi_reg;    
      pipe_ho(3 DOWNTO 0) <= pipe_ho(4 DOWNTO 1);    
      pipe_ntsc(4) <= ntsc_reg;    
      pipe_ntsc(3 DOWNTO 0) <= pipe_ntsc(4 DOWNTO 1);    
   END PROCESS;

   -- process the luna data
   PROCESS
   BEGIN
      WAIT UNTIL (clk'EVENT AND clk = '1');
      IF (ena_luma_reg = '1') THEN
         Y_rg1(9 DOWNTO 0) <= ycrcb_in_reg(9 DOWNTO 0);    
      ELSE
         Y_rg1(9 DOWNTO 0) <= Y_rg1(9 DOWNTO 0);    
      END IF;
   END PROCESS;

   -- 3 clock delay
   PROCESS
   BEGIN
      WAIT UNTIL (clk'EVENT AND clk = '1');
      Y_rg2(9 DOWNTO 0) <= Y_rg1(9 DOWNTO 0);    
      Y_rg3(9 DOWNTO 0) <= Y_rg2(9 DOWNTO 0);    
      Y_rg4(9 DOWNTO 0) <= Y_rg3(9 DOWNTO 0);    
   END PROCESS;

   -- process the Cr data
   PROCESS
   BEGIN
      WAIT UNTIL (clk'EVENT AND clk = '1');
      IF (rst = '1') THEN
         chroma_red_rg1(9 DOWNTO 0) <= "0000000000";    
      ELSE
         IF (ena_chroma_red_reg = '1') THEN
            chroma_red_rg1(9 DOWNTO 0) <= ycrcb_in_reg(9 DOWNTO 0);    
         ELSE
            chroma_red_rg1(9 DOWNTO 0) <= chroma_red_rg1(9 DOWNTO 0);    
         END IF;
      END IF;
   END PROCESS;

   -- 3 clock delay
   PROCESS
   BEGIN
      WAIT UNTIL (clk'EVENT AND clk = '1');
      chroma_red_rg2(9 DOWNTO 0) <= chroma_red_rg1(9 DOWNTO 0);    
      chroma_red_rg3(9 DOWNTO 0) <= chroma_red_rg2(9 DOWNTO 0);    
      chroma_red_rg4(9 DOWNTO 0) <= chroma_red_rg3(9 DOWNTO 0);    
   END PROCESS;

   -- process the Cb data
   PROCESS
   BEGIN
      WAIT UNTIL (clk'EVENT AND clk = '1');
      IF (rst = '1') THEN
         chroma_blue_rg1(9 DOWNTO 0) <= "0000000000";    
      ELSE
         IF (ena_chroma_blue_reg = '1') THEN
            chroma_blue_rg1(9 DOWNTO 0) <= ycrcb_in_reg(9 DOWNTO 0);    
         ELSE
            chroma_blue_rg1(9 DOWNTO 0) <= chroma_blue_rg1(9 DOWNTO 0);    
         END IF;
      END IF;
   END PROCESS;

   -- 4 clock delay
   PROCESS
   BEGIN
      WAIT UNTIL (clk'EVENT AND clk = '1');
      chroma_blue_rg2(9 DOWNTO 0) <= chroma_blue_rg1(9 DOWNTO 0);    
      chroma_blue_rg3(9 DOWNTO 0) <= chroma_blue_rg2(9 DOWNTO 0);    
      chroma_blue_rg4(9 DOWNTO 0) <= chroma_blue_rg3(9 DOWNTO 0);    
      chroma_blue_rg5(9 DOWNTO 0) <= chroma_blue_rg4(9 DOWNTO 0);    
   END PROCESS;

END behavioral;