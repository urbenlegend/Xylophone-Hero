--/*************************************************************************
-- ** 
-- ** Module: ycrcb2rgb
-- **
-- ** Generic Equations:
-- ***************************************************************************/

library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use IEEE.Numeric_STD.all;


entity ycrcb2rgb is
  port (Y,Cr,Cb : in std_logic_vector(9 downto 0); 
        clk,rst : in std_logic;
          R,G,B : out std_logic_vector(7 downto 0));
 end ycrcb2rgb;


architecture behavioral of ycrcb2rgb is

signal Y_reg,CR_reg,CB_reg: std_logic_vector(9 downto 0);
signal X_int,A_int,B1_int,B2_int,C_int: std_logic_vector(21 downto 0);
signal Y_int1,CR_int1,CB_int1: std_logic_vector (10 downto 0);
signal R_int,G_int,B_int: std_logic_vector(21 downto 0);

begin

PROCESS (clk,rst)
  begin
   if (rst = '1') then
      Y_reg <= "0000000000"; CR_reg <= "0000000000";CB_reg <= "0000000000";
   elsif (rising_edge (clk)) then
      Y_reg <= Y; CR_reg <= Cr;CB_reg <= Cb;
   end if;
end PROCESS;

Y_int1 <= (('0' & Y_reg) - "00001000000"); 
CR_int1 <= (('0' & CR_reg) - "01000000000");
CB_int1 <= (('0' & CB_reg) - "01000000000");

PROCESS (clk,rst)
  begin
   if (rst = '1') then
      X_int <= (others => '0'); 
      A_int <= (others => '0'); 
      B1_int <= (others => '0'); 
      B2_int <= (others => '0');
      C_int <= (others => '0');
   elsif  (rising_edge (clk)) then
      X_int  <= ("00100101010" * (Y_int1));--(Y_reg - "1000000"));-- Y_reg - 64
      A_int  <= ("00110011000" * ( CR_int1));--(CR_reg - "1000000000"));  -- Cr_reg - 512
      B1_int <= ("00011010000" * ( CR_int1));--(CR_reg - "1000000000")); 
      B2_int <= ("00001100100" * (CB_int1));--(CB_reg - "1000000000")); -- Cb_reg - 512
      C_int  <= ("01000000100" * (CB_int1));--(CB_reg - "1000000000")); 
   end if;
end PROCESS;


PROCESS (clk,rst)
  begin
   if (rst = '1') then
      R_int <= (others => '0'); 
      G_int <= (others => '0'); 
      B_int <= (others => '0'); 
   elsif  (rising_edge (clk)) then
      R_int <= X_int + A_int;
      G_int <= X_int - B1_int - B2_int;  
      B_int <= X_int + C_int; 
   end if;
end PROCESS;

PROCESS (R_int)
   begin
      if (R_int(21) = '1') then
          R <= "00000000";
      elsif (R_int(20 downto 18) = "000") then
          R <= R_int(17 downto 10);
      elsif (R_int(18) = '1') then
          R <= "11111111";
      end if;
end PROCESS;

PROCESS (G_int)
   begin
      if (G_int(21) = '1') then
          G <= "00000000";
      elsif (G_int(20 downto 18) = "000") then
          G <= G_int(17 downto 10);
      elsif (G_int(18) = '1') then
          G <= "11111111";
      end if;
end PROCESS;

PROCESS (B_int)
   begin
      if (B_int(21) = '1') then
          B <= "00000000";
      elsif (B_int(20 downto 18) = "000") then
          B <= B_int(17 downto 10);
      elsif (B_int(18) = '1') then
          B <= "11111111";
      end if;
end PROCESS;

end behavioral;