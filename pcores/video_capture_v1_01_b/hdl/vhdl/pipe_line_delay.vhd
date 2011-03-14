----------------------------------------------------------------------------------------------
--
--      Design name        : PIPE_LINE_DELAY
--
-- Description: This module aligns the sync and blank signals with the video data.
--
----------------------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY PIPE_LINE_DELAY IS
   PORT (
      clk                     : IN std_logic;   
      rst                     : IN std_logic;   
      hsync_in                : IN std_logic;   
      vsync_in                : IN std_logic;   
      blank_in                : IN std_logic;   
      comp_sync_in            : IN std_logic;   
      hsync_out               : OUT std_logic;   
      vsync_out               : OUT std_logic;   
      blank_out               : OUT std_logic;   
      comp_sync_out           : OUT std_logic);   
END PIPE_LINE_DELAY;

ARCHITECTURE behavioral OF PIPE_LINE_DELAY IS


   SIGNAL pipe0                    :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL pipe1                    :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL pipe2                    :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL pipe3                    :  std_logic_vector(3 DOWNTO 0);   
   SIGNAL pipe4                    :  std_logic_vector(3 DOWNTO 0);   

BEGIN
   hsync_out <= pipe4(0) ;
   vsync_out <= pipe4(1) ;
   blank_out <= pipe4(2) ;
   comp_sync_out <= pipe4(3) ;

   PROCESS (clk,rst)
   BEGIN
		IF (rst = '1') THEN
			pipe0 <= "0000";    
			pipe1 <= "0000";    
			pipe2 <= "0000";    
			pipe2 <= "0000";    
			pipe3 <= "0000";    
			pipe4 <= "0000";
		ELSIF (clk'EVENT AND clk = '1') THEN
			pipe0(0) <= hsync_in;    
			pipe0(1) <= vsync_in;    
			pipe0(2) <= blank_in;    
			pipe0(3) <= comp_sync_in;    
			pipe1(3 DOWNTO 0) <= pipe0(3 DOWNTO 0);    
			pipe2(3 DOWNTO 0) <= pipe1(3 DOWNTO 0);    
			pipe3(3 DOWNTO 0) <= pipe2(3 DOWNTO 0);    
			pipe4(3 DOWNTO 0) <= pipe3(3 DOWNTO 0);    
		END IF;
   END PROCESS;

END behavioral;