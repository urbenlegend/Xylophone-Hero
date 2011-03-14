----------------------------------------------------------------------------------------------
--
--      Design name        : NEG_EDGE_DETECT
--
--  Description: This module creates a one clock wide pulse on the negative 
--  			   transition of the "data_in" signal. This is used to reset
--			   the vertical line counter in the SPECIAL_SVGA_TIMING_GENERATION
--		       module on the transition of the "FIELD" bit in the timing reference code.
--
--
----------------------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY NEG_EDGE_DETECT IS
   PORT (
      clk                     : IN std_logic;   
      data_in                 : IN std_logic;   
      reset                   : IN std_logic;   
      one_shot_out            : OUT std_logic);   
END NEG_EDGE_DETECT;

ARCHITECTURE behavioral OF NEG_EDGE_DETECT IS


   SIGNAL PRESENT_STATE            :  std_logic_vector(1 DOWNTO 0);   
   SIGNAL NEXT_STATE               :  std_logic_vector(1 DOWNTO 0);   
   CONSTANT  START                 :  std_logic_vector(1 DOWNTO 0) := "00";    
   CONSTANT  LOW                   :  std_logic_vector(1 DOWNTO 0) := "01";    
   CONSTANT  HIGH                  :  std_logic_vector(1 DOWNTO 0) := "10";    

BEGIN

   PROCESS (clk,reset)
   BEGIN
      IF (reset = '1') THEN
         PRESENT_STATE <= START;    
      ELSIF (clk'EVENT AND clk = '1') THEN
         PRESENT_STATE <= NEXT_STATE;    
      END IF;
   END PROCESS;

   PROCESS (PRESENT_STATE, data_in)
   BEGIN
      CASE PRESENT_STATE IS
         WHEN START =>
                  IF (NOT data_in = '1') THEN
                     NEXT_STATE <= LOW;    
                  ELSE
                     NEXT_STATE <= START;    
                  END IF;
         WHEN LOW =>
                  NEXT_STATE <= HIGH;    
         WHEN HIGH =>
                  IF (NOT data_in = '1') THEN
                     NEXT_STATE <= HIGH;    
                  ELSE
                     NEXT_STATE <= START;    
                  END IF;
         WHEN OTHERS  =>
                  NEXT_STATE <= START;    
         
      END CASE;
   END PROCESS;
   one_shot_out <= PRESENT_STATE(0) ;

END behavioral;