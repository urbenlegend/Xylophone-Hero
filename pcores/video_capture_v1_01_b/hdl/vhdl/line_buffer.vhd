----------------------------------------------------------------------------------------------
--
--      Design name        : LINE_BUFFER
--
----------------------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LINE_BUFFER IS
   PORT (
      read_clk                : IN std_logic;   
      read_address            : IN std_logic_vector(10 DOWNTO 0);   
      read_enable             : IN std_logic;   
      read_red_data           : OUT std_logic_vector(7 DOWNTO 0);   
      read_green_data         : OUT std_logic_vector(7 DOWNTO 0);   
      read_blue_data          : OUT std_logic_vector(7 DOWNTO 0);   
      write_clk               : IN std_logic;   
      write_address           : IN std_logic_vector(10 DOWNTO 0);   
      write_enable            : IN std_logic;   
      write_red_data          : IN std_logic_vector(7 DOWNTO 0);   
      write_green_data        : IN std_logic_vector(7 DOWNTO 0);   
      write_blue_data         : IN std_logic_vector(7 DOWNTO 0));   
END LINE_BUFFER;

ARCHITECTURE behavioral OF LINE_BUFFER IS

COMPONENT RAMB16_S9_S9
   PORT (
      DOA                     : OUT std_logic_vector(7 DOWNTO 0);   
      DOB                     : OUT std_logic_vector(7 DOWNTO 0);   
      DOPA0                   : OUT std_logic;   
      DOPB0                   : OUT std_logic;   
      ADDRA                   : IN std_logic_vector(10 DOWNTO 0);   
      ADDRB                   : IN std_logic_vector(10 DOWNTO 0);   
      CLKA                    : IN std_logic;   
      CLKB                    : IN std_logic;   
      DIA                     : IN std_logic_vector(7 DOWNTO 0);   
      DIB                     : IN std_logic_vector(7 DOWNTO 0);   
      DIPA0                   : IN std_logic;   
      DIPB0                   : IN std_logic;   
      ENA                     : IN std_logic;   
      ENB                     : IN std_logic;   
      SSRA                    : IN std_logic;   
      SSRB                    : IN std_logic;   
      WEA                     : IN std_logic;   
      WEB                     : IN std_logic);   
END COMPONENT;


BEGIN
   RED_DATA_RAM : RAMB16_S9_S9 
      PORT MAP (
         DOA => open,
         DOPA0 => open,
         ADDRA => write_address(10 DOWNTO 0),
         CLKA => write_clk,
         DIA => write_red_data(7 DOWNTO 0),

         DIPA0 => '1',
         ENA => write_enable,
         WEA => '1',
         SSRA => '0',
         DOB => read_red_data(7 DOWNTO 0),
         DOPB0 => open,
         ADDRB => read_address(10 DOWNTO 0),
         CLKB => read_clk,
         DIB => "00000000",
         DIPB0 => '0',
         ENB => read_enable,
         SSRB => '0',
         WEB => '0');   
   
   GREEN_DATA_RAM : RAMB16_S9_S9 
      PORT MAP (
         DOA => open,
         DOPA0 => open,
         ADDRA => write_address(10 DOWNTO 0),
         CLKA => write_clk,
         DIA => write_green_data(7 DOWNTO 0),
         DIPA0 => '0',
         ENA => write_enable,
         WEA => '1',
         SSRA => '0',
         DOB => read_green_data(7 DOWNTO 0),
         DOPB0 => open,
         ADDRB => read_address(10 DOWNTO 0),
         CLKB => read_clk,
         DIB => "00000000",
         DIPB0 => '0',
         ENB => read_enable,
         SSRB => '0',
         WEB => '0');   
   
   BLUE_DATA_RAM : RAMB16_S9_S9 
      PORT MAP (
         DOA => open,
         DOPA0 => open,
         ADDRA => write_address(10 DOWNTO 0),
         CLKA => write_clk,
         DIA => write_blue_data(7 DOWNTO 0),
         DIPA0 => '0',
         ENA => write_enable,
         WEA => '1',
         SSRA => '0',
         DOB => read_blue_data(7 DOWNTO 0),
         DOPB0 => open,
         ADDRB => read_address(10 DOWNTO 0),
         CLKB => read_clk,
         DIB => "00000000",
         DIPB0 => '0',
         ENB => read_enable,
         SSRB => '0',         
         WEB => '0');   
  
END behavioral;
