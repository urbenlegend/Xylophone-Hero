----------------------------------------------------------------------------------------------
--
--      Design name        : video_capture
--
----------------------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY video_capture IS
   PORT (
      YCrCb_in                : IN std_logic_vector(9 DOWNTO 2);   
      LLC_CLOCK               : IN std_logic;   
      PIXEL_CLOCK             : OUT std_logic;
      H_SYNC_Z                : OUT std_logic;   
      V_SYNC_Z                : OUT std_logic;   
      BLANK_Z                 : OUT std_logic;   
      COMP_SYNC               : OUT std_logic;   
      R                       : OUT std_logic_vector(7 DOWNTO 0);   
      G                       : OUT std_logic_vector(7 DOWNTO 0);   
      B                       : OUT std_logic_vector(7 DOWNTO 0);   
      RESET_VDEC1_Z           : OUT std_logic;   
      VDEC1_OE_Z              : OUT std_logic;   
      VDEC1_PWRDN_Z           : OUT std_logic;   
      system_dcm_locked       : IN std_logic;
      white_count_thresh      : IN std_logic_vector(9 DOWNTO 0);
      black_count_thresh      : IN std_logic_vector(9 DOWNTO 0);
      white_color_thresh      : IN std_logic_vector(7 DOWNTO 0);
      black_color_thresh      : IN std_logic_vector(7 DOWNTO 0);
      calibrate               : IN std_logic_vector(3 DOWNTO 0);
      BW                      : IN std_logic;
      clk_27_out              : OUT std_logic;
      frame                   : OUT std_logic;
      game_mode               : IN std_logic;
	  EXP_IO_44               : OUT std_logic
      );
END video_capture;

ARCHITECTURE behavioral OF video_capture IS

   COMPONENT LINE_BUFFER
      PORT (
         read_clk                : IN  std_logic;
         read_address            : IN  std_logic_vector(10 DOWNTO 0);
         read_enable             : IN  std_logic;
         read_red_data           : OUT std_logic_vector(7 DOWNTO 0);
         read_green_data         : OUT std_logic_vector(7 DOWNTO 0);
         read_blue_data          : OUT std_logic_vector(7 DOWNTO 0);
         write_clk               : IN  std_logic;
         write_address           : IN  std_logic_vector(10 DOWNTO 0);
         write_enable            : IN  std_logic;
         write_red_data          : IN  std_logic_vector(7 DOWNTO 0);
         write_green_data        : IN  std_logic_vector(7 DOWNTO 0);
         write_blue_data         : IN  std_logic_vector(7 DOWNTO 0));
   END COMPONENT;

   COMPONENT NEG_EDGE_DETECT
      PORT (
         clk                     : IN  std_logic;
         data_in                 : IN  std_logic;
         reset                   : IN  std_logic;
         one_shot_out            : OUT std_logic);
   END COMPONENT;

   COMPONENT PIPE_LINE_DELAY
      PORT (
         clk                     : IN  std_logic;
         rst                     : IN  std_logic;
         hsync_in                : IN  std_logic;
         vsync_in                : IN  std_logic;
         blank_in                : IN  std_logic;
         comp_sync_in            : IN  std_logic;
         hsync_out               : OUT std_logic;
         vsync_out               : OUT std_logic;
         blank_out               : OUT std_logic;
         comp_sync_out           : OUT std_logic);
   END COMPONENT;

   COMPONENT SPECIAL_SVGA_TIMING_GENERATION
      PORT (
         pixel_clock             : IN  std_logic;
         reset                   : IN  std_logic;
         h_synch_delay           : OUT std_logic;
         v_synch_delay           : OUT std_logic;
         comp_synch              : OUT std_logic;
         blank                   : OUT std_logic;
         char_line_count         : OUT std_logic_vector(2 DOWNTO 0);
         char_address            : OUT std_logic_vector(13 DOWNTO 0);
         char_pixel              : OUT std_logic_vector(2 DOWNTO 0);
         pixel_count             : OUT std_logic_vector(10 DOWNTO 0);
         row_count             : OUT std_logic_vector(9 DOWNTO 0));
   END COMPONENT;

   COMPONENT lf_decode
      PORT (
         rst                     : IN  std_logic;
         clk                     : IN  std_logic;
         YCrCb_in                : IN  std_logic_vector(9 DOWNTO 0);
         YCrCb_out               : OUT std_logic_vector(9 DOWNTO 0);
         NTSC_out                : OUT std_logic;
         Fo                      : OUT std_logic;
         Vo                      : OUT std_logic;
         Ho                      : OUT std_logic);
   END COMPONENT;


	-- Component Declaration for BUFG should be placed
	-- after architecture statement but before begin keyword
	component BUFG
		port (O : out STD_ULOGIC;
		I : in STD_ULOGIC);
	end component;

	-- Component Declaration for IBUF should be placed 
	-- after architecture statement but before begin keyword 

	component IBUFG
   	-- synthesis translate_off
   		generic (
       		IOSTANDARD: bit_vector := "LVCMOS25");
   	-- synthesis translate_on
	   	port (O : out STD_ULOGIC;
			  I : in STD_ULOGIC);
	end component;



	COMPONENT OFDDRRSE IS
   	PORT (
		Q                       : OUT std_logic;   
   	   	C0                      : IN std_logic;   
      	C1                      : IN std_logic;   
	    CE                      : IN std_logic;   
   	   	D0                      : IN std_logic;   
      	D1                      : IN std_logic;   
      	R                       : IN std_logic;   
      	S                       : IN std_logic);   
	END COMPONENT;

	COMPONENT vp422_444_dup IS
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
	END COMPONENT;

	COMPONENT YCrCb2RGB IS
	   PORT (
			R                       : OUT std_logic_vector(7 DOWNTO 0);   
			G                       : OUT std_logic_vector(7 DOWNTO 0);   
			B                       : OUT std_logic_vector(7 DOWNTO 0);   
      		clk                     : IN std_logic;   
	      	rst                     : IN std_logic;   
   	   		Y                       : IN std_logic_vector(9 DOWNTO 0);   
      		Cr                      : IN std_logic_vector(9 DOWNTO 0);   
	      	Cb                      : IN std_logic_vector(9 DOWNTO 0));   
	END COMPONENT;

   SIGNAL VDEC1_OE_Z0              :  std_logic;   
   SIGNAL VDEC1_PWRDN_Z1           :  std_logic;   
   SIGNAL write_address            :  std_logic_vector(10 DOWNTO 0);   
   SIGNAL read_enable_lb0          :  std_logic;   
   SIGNAL write_enable_lb0         :  std_logic;   
   SIGNAL crop                     :  std_logic;   
   SIGNAL h_synch_delay            :  std_logic;   
   SIGNAL v_synch_delay            :  std_logic;   
   SIGNAL comp_synch               :  std_logic;   
   SIGNAL blank                    :  std_logic;   
   SIGNAL rst                      :  std_logic;   
   SIGNAL YCrCb_out_422            :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Fo_422                   :  std_logic;   
   SIGNAL Vo_422                   :  std_logic;   
   SIGNAL Ho_422                   :  std_logic;   
   SIGNAL Fi_422                   :  std_logic;   
   SIGNAL Vi_422                   :  std_logic;   
   SIGNAL Hi_422                   :  std_logic;   
   SIGNAL Fo_444                   :  std_logic;
   SIGNAL Vo_444                   :  std_logic;   
   SIGNAL Ho_444                   :  std_logic;   
   SIGNAL ceo_444                  :  std_logic;   
   SIGNAL YCrCb_in_422             :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Y_out_444                :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Cr_out_444               :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Cb_out_444               :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Y_in_444                 :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Cr_in_444                :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Cb_in_444                :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL Red                      :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL Green                    :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL Blue                     :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL hsync                    :  std_logic;   
   SIGNAL vsync                    :  std_logic;   
   SIGNAL hblank                   :  std_logic;   
   SIGNAL llc_clock_i              :  std_logic;   
   SIGNAL clock_27                 :  std_logic;   
   SIGNAL clk_27                   :  std_logic;   
   SIGNAL clk_13                   :  std_logic;   
   SIGNAL clock_13                 :  std_logic;   
   SIGNAL clock_40                 :  std_logic;   
   SIGNAL clk_40                   :  std_logic;   
   SIGNAL system_dcm_rst           :  std_logic;   
   SIGNAL low                      :  std_logic;   
   SIGNAL high                     :  std_logic;   
   SIGNAL pixel_count              :  std_logic_vector(10 DOWNTO 0);   
   SIGNAL read_enable_lb1          :  std_logic;   
   SIGNAL write_enable_lb1         :  std_logic;   
   SIGNAL write_red_data           :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL write_green_data         :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL write_blue_data          :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL read_red_data_lb0        :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL read_green_data_lb0      :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL read_blue_data_lb0       :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL read_red_data_lb1        :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL read_green_data_lb1      :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL read_blue_data_lb1       :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL one_shot_out             :  std_logic;   
   SIGNAL reset_timing_gen         :  std_logic;   
   SIGNAL char_line_count          :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL char_address             :  std_logic_vector(13 DOWNTO 0);   
   SIGNAL char_pixel               :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL hsync_in                 :  std_logic;   
   SIGNAL vsync_in                 :  std_logic;   
   SIGNAL blank_in                 :  std_logic;   
   SIGNAL comp_synch_in            :  std_logic;   
   SIGNAL hsync_out                :  std_logic;   
   SIGNAL vsync_out                :  std_logic;   
   SIGNAL blank_out                :  std_logic;   
   SIGNAL comp_synch_out           :  std_logic;   
   SIGNAL NTSC_out                 :  std_logic;   
   SIGNAL concat_YCrCb_in          :  std_logic_vector(9 DOWNTO 0);   
   SIGNAL comp_sync_in             :  std_logic;   
   SIGNAL ntsc_out_o               :  std_logic;   
   SIGNAL reset                    :  std_logic;   
   SIGNAL pixel_flag               :  std_logic;
   SIGNAL line_count               :  std_logic_vector(9 DOWNTO 0);
   SIGNAL R_int                    :  std_logic_vector(7 DOWNTO 0);
   SIGNAL G_int                    :  std_logic_vector(7 DOWNTO 0);
   SIGNAL B_int                    :  std_logic_vector(7 DOWNTO 0);
   SIGNAL grayscale                :  std_logic_vector(7 DOWNTO 0);
   type v_array_part is array (8 downto 0) of std_logic_vector(10 downto 0);
   type v_array is array (7 downto 0) of v_array_part;
   shared variable vert_lines      :  v_array;
   SIGNAL mallet_top               :  std_logic_vector(9 downto 0);
   SIGNAL mallet_vmid              :  std_logic_vector(9 downto 0);
   SIGNAL mallet_bot               :  std_logic_vector(9 downto 0);
   SIGNAL mallet_left              :  std_logic_vector(10 downto 0);
   SIGNAL mallet_hmid              :  std_logic_vector(10 downto 0);
   SIGNAL mallet_right             :  std_logic_vector(10 downto 0);
   SIGNAL mallet_width             :  std_logic_vector(10 downto 0);
   type lines is array (8 downto 0) of std_logic_vector (9 downto 0);
   shared variable ball_sizes      :  lines;
   shared variable sheet_whores    :  lines;
   SIGNAL hit                      :  std_logic_vector(3 downto 0);
   SIGNAL note_hit                 :  std_logic_vector(3 downto 0);
   
BEGIN
   VDEC1_OE_Z <= VDEC1_OE_Z0;
   VDEC1_PWRDN_Z <= VDEC1_PWRDN_Z1;
   RESET_VDEC1_Z <= '1' ;
   VDEC1_OE_Z0 <= '0' ;
   VDEC1_PWRDN_Z1 <= '1' ;
   low <= '0' ;
   high <= '1' ;
   read_enable_lb1 <= NOT read_enable_lb0 ;
   write_enable_lb1 <= NOT write_enable_lb0 ;
   Fi_422 <= Fo_422 ;
   Vi_422 <= Vo_422 ;
   Hi_422 <= Ho_422 ;
   YCrCb_in_422(9 DOWNTO 0) <= YCrCb_out_422(9 DOWNTO 0) ;
   Y_in_444(9 DOWNTO 0) <= Y_out_444(9 DOWNTO 0) ;
   Cr_in_444(9 DOWNTO 0) <= Cr_out_444(9 DOWNTO 0) ;
   Cb_in_444(9 DOWNTO 0) <= Cb_out_444(9 DOWNTO 0) ;
   H_SYNC_Z <= hsync_out ;
   V_SYNC_Z <= vsync_out ;
   BLANK_Z <= NOT blank_out ;
   COMP_SYNC <= '0' ;
   rst <= NOT system_dcm_locked ;
   write_red_data(7 DOWNTO 0) <= Red(7 DOWNTO 0) ;
   write_green_data(7 DOWNTO 0) <= Green(7 DOWNTO 0) ;
   write_blue_data(7 DOWNTO 0) <= Blue(7 DOWNTO 0) ;
   reset_timing_gen <= rst OR one_shot_out ;
   hsync_in <= h_synch_delay ;
   vsync_in <= v_synch_delay ;
   blank_in <= blank ;
   comp_sync_in <= comp_synch ;
   concat_YCrCb_in <= YCrCb_in(9 DOWNTO 2) & "00" ;

	-- IBUFG: Single-ended global clock input buffer
	-- All FPGA
	-- Xilinx HDL Libraries Guide version 7.1i
	LLC_INPUT_BUF : IBUFG
	-- Edit the following generic to specify the I/O standard for this port.
	--		generic map (
	--		IOSTANDARD => "LVCMOS25")
		port map (
			O => clk_27, -- Clock buffer output
			I => LLC_CLOCK -- Clock buffer input (connect directly to top-level port)
		);
	-- End of IBUFG_inst instantiation

  
	-- Component Instantiation for BUFG should be placed
	-- in architecture after the begin keyword
	CLK_13MHZ_BUF : BUFG
		port map (O => clk_13,
		I => ceo_444);
   
   PIXEL_CLOCK_DDR_FF : OFDDRRSE 
      PORT MAP (
         Q => PIXEL_CLOCK,
         C0 => clk_27,
         C1 => NOT clk_27,
         CE => high,
         D0 => low,
         D1 => high,
         R => reset,
         S => low);   
   
   lf_decode_i : lf_decode 
      PORT MAP (
         rst => rst,
         clk => clk_27,
         YCrCb_in => concat_YCrCb_in,
         YCrCb_out => YCrCb_out_422,
         NTSC_out => NTSC_out,
         Fo => Fo_422,
         Vo => Vo_422,
         Ho => Ho_422);   
   
	vp422_444_dup_i : vp422_444_dup 
      PORT MAP (
         rst => rst,
         clk => clk_27,
         ycrcb_in => YCrCb_in_422,
         ntsc_in => NTSC_out,
         fi => Fi_422,
         vi => Vi_422,
         hi => Hi_422,
         ceo => ceo_444,
         ntsc_out_o => ntsc_out_o,
         fo => Fo_444,
         vo => Vo_444,
         ho => Ho_444,
         y_out => Y_out_444,
         cr_out => Cr_out_444,
         cb_out => Cb_out_444);   
   
   YCrCb2RGB_i : YCrCb2RGB 
      PORT MAP (
         R => Red,
         G => Green,
         B => Blue,
         clk => clk_13,
         rst => rst,
         Y => Y_in_444,
         Cr => Cr_in_444,
         Cb => Cb_in_444);   
   

   PROCESS (Ho_444, rst)
   BEGIN
      IF (rst = '1') THEN
         read_enable_lb0 <= '0';    
         write_enable_lb0 <= '1';    
      ELSIF (Ho_444'EVENT AND Ho_444 = '1') THEN
         read_enable_lb0 <= NOT read_enable_lb0;    
         write_enable_lb0 <= NOT write_enable_lb0;    
      END IF;
   END PROCESS;

   PROCESS (clk_13, Ho_444)
   BEGIN
      IF (Ho_444 = '1') THEN
         write_address <= "00000000000";    
      ELSIF (clk_13'EVENT AND clk_13 = '1') THEN
         write_address <= write_address + "00000000001";    
      END IF;
   END PROCESS;
   LB0 : LINE_BUFFER 
      PORT MAP (
         read_clk => clk_27,
         read_address => pixel_count,
         read_enable => read_enable_lb0,
         read_red_data => read_red_data_lb0,
         read_green_data => read_green_data_lb0,
         read_blue_data => read_blue_data_lb0,
         write_clk => clk_13,
         write_address => write_address,
         write_enable => write_enable_lb0,
         write_red_data => write_red_data,
         write_green_data => write_green_data,
         write_blue_data => write_blue_data);   
   
   LB1 : LINE_BUFFER 
      PORT MAP (
         read_clk => clk_27,
         read_address => pixel_count,
         read_enable => read_enable_lb1,
         read_red_data => read_red_data_lb1,
         read_green_data => read_green_data_lb1,
         read_blue_data => read_blue_data_lb1,
         write_clk => clk_13,
         write_address => write_address,
         write_enable => write_enable_lb1,
         write_red_data => write_red_data,
         write_green_data => write_green_data,
         write_blue_data => write_blue_data);   
   

   PROCESS (pixel_count, rst)
   BEGIN
      IF (rst = '1') THEN
         crop <= '1';    
      ELSIF (clk_27'EVENT AND clk_27 = '1') THEN
         IF (pixel_count < "00000000101") THEN
            crop <= '1';    
         ELSE
            IF (pixel_count > "01011001010") THEN
               crop <= '1';    
            ELSE
               crop <= '0';    
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   --################################################
   --##
   --## Communicate with PPC.
   --##
   --################################################
--   PROCESS (clk_27, line_count, pixel_count)
--   BEGIN
--      clk_27_out <= clk_27;
--      
--      if (line_count < "1000000000") then
--         frame <= '1';
--      else
--         frame <= '0';
--      end if;
--   END PROCESS;
   
   --##########################################
   --##
   --## Sound Generator.
   --##   
   --##########################################
   PROCESS (clk_27, note_hit)
     variable counter : integer := 0;
     variable toggle : std_logic:= '0';
     variable period : integer := 764526;
   BEGIN
     if (clk_27 = '1' AND clk_27'EVENT) THEN
	    counter := counter + 1;
        
        -- flip output when time reaches period
        if(counter > period/2) then
            if(toggle = '1') then
                toggle := '0';
            else
                toggle := '1';
            end if;
            
            counter := 0;
        end if;
--        -- gate control
--        if(gate = '0') then
--            toggle := '0';
--        end if;
        if note_hit = "0001"  then 
	      period := 764526;
        elsif note_hit = "0010" then 
		  period := 721501;
        elsif note_hit = "0011" then 
		  period := 606796;
        elsif note_hit = "0100" then 
		  period := 512821;
        elsif note_hit = "0101" then 
	      period := 429000;
        elsif note_hit = "0110" then 
		  period := 360750;
        elsif note_hit = "0111" then 
		  period := 303398;
        elsif note_hit = "1000" then 
		  period := 255102;
--      elsif note < 24 then period := 214500;
--      elsif note < 25 then period := 202470;
        else 
		  period := 10000000;
        end if;

        
        -- frequency table for 24 notes
	   EXP_IO_44 <= toggle;
	 end if;
   END PROCESS;

   --##########################################
   --##
   --##  Read video signal from camera.
   --##
   --##########################################
   PROCESS (clk_27, rst, read_enable_lb0)
      variable min   : std_logic_vector (8 downto 0);
      variable max   : std_logic_vector (8 downto 0);
   BEGIN
      IF (rst = '1') THEN
         grayscale (7 DOWNTO 0) <= "00000000";
      ELSIF (clk_27'EVENT AND clk_27 = '1') THEN
         IF (crop = '1') THEN
            grayscale (7 DOWNTO 0) <= "00000000";
         ELSE
   			  if (read_enable_lb0 = '1') THEN
               R_int(7 DOWNTO 0) <= read_red_data_lb0(7 DOWNTO 0);    
               G_int(7 DOWNTO 0) <= read_green_data_lb0(7 DOWNTO 0);    
               B_int(7 DOWNTO 0) <= read_blue_data_lb0(7 DOWNTO 0);    
            else
               R_int(7 DOWNTO 0) <= read_red_data_lb1(7 DOWNTO 0);    
               G_int(7 DOWNTO 0) <= read_green_data_lb1(7 DOWNTO 0);    
               B_int(7 DOWNTO 0) <= read_blue_data_lb1(7 DOWNTO 0);    
            END IF;
            
            -- Find min/max, then get grayscale: (max + min) / 2
            if (R_int > G_int) then
               max (7 downto 0) := R_int;
               min (7 downto 0) := G_int;
            else
               max (7 downto 0) := G_int;
               min (7 downto 0) := R_int;
            end if;
            if (B_int > max (7 downto 0)) then
               max (7 downto 0) := B_int;
            elsif (B_int < min (7 downto 0)) then
               min (7 downto 0) := B_int;
            end if;
            grayscale <= to_stdlogicvector (to_bitvector (max + min) srl 1) (7 downto 0);
         END IF;
      END IF;
   END PROCESS;
   
   --################################################
   --##
   --## Calibration for xylophone sheet.
   --##
   --################################################
   PROCESS (clk_27, rst, calibrate)
     variable black_count : std_logic_vector (9 downto 0);
     variable white_count : std_logic_vector (9 downto 0);
     variable counter : std_logic_vector (3 downto 0) := "0000";
     variable calib_stage : std_logic_vector (2 downto 0) := "000";
     variable tmp_sheet_bot : std_logic_vector (9 downto 0);
     variable vert_probe : std_logic_vector (9 downto 0);
     variable vert_sect : std_logic_vector (2 downto 0);
     variable horiz_sect : std_logic_vector (3 downto 0);
     variable vert_div   :  std_logic_vector(6 DOWNTO 0);
     variable save : std_logic;
   BEGIN
      if (clk_27'EVENT and clk_27 = '1') then
         if calibrate = "0010" then
            calib_stage := "001";
         end if;
         
         if pixel_count = "0000000000" then
            black_count := "0000000000";
            white_count := "0000000000";
            
            if calib_stage = "001" and line_count = "0000000000" then
            --###################################################
            --## Calibration stage 1: wait for new frame.
            --###################################################
               calib_stage := "010";
            elsif calib_stage <= "011" then
               if counter = "1111" then
                  counter := "0000";
               elsif counter > "0000" then
                  counter := counter + 1;
               end if;
            end if;
         elsif calib_stage = "010" then
            --###################################################
            --## Calibration stage 2: find top of sheet.
            --###################################################
            if grayscale <= black_color_thresh then
               black_count := black_count + 1;
               if black_count >= black_count_thresh and line_count > "10000" then
                  -- Enough black pixels found; start counter.
                  counter := "0001";
               end if;
            elsif grayscale >= white_color_thresh then
               white_count := white_count + 1;
               if white_count >= white_count_thresh and line_count > "1000" and counter > "0000" then
                  -- Enough white pixels found with counter active. Mark top of sheet.
                  counter := "0000";
                  calib_stage := "011";
                  sheet_whores(0) := line_count;
               end if;
            end if;
         elsif calib_stage = "011" then
            --###################################################
            --## Calibration stage 3: find bottom of sheet.
            --###################################################
            if line_count = "000000000" then
               -- At the end of the frame, jump to next stage.
               calib_stage := "100";
               vert_sect := "000";
               horiz_sect := "0000";
               sheet_whores(8) := tmp_sheet_bot;
            end if;
            
            if grayscale >= white_color_thresh then
               white_count := white_count + 1;
               if white_count >= white_count_thresh then
                  -- Enough white pixels found; start counter.
                  counter := "0001";
               end if;
            elsif grayscale <= black_color_thresh then
               black_count := black_count + 1;
               if black_count >= black_count_thresh and counter > "0000" then
                  -- Enough black pixels found with counter active. Mark bottom of sheet.
                  tmp_sheet_bot := line_count;
                  counter := "0000";
               end if;
            end if;
         elsif calib_stage = "100" then
            --###################################################
            --## Calibration stage 4: set up for last stage.
            --###################################################
            -- Get the vertical division of lines. Slip into 8 rows
            vert_div := shr (sheet_whores(8) - sheet_whores(0), "11");
            calib_stage := "101";
         elsif calib_stage = "101" then
            --###################################################
            --## Calibration stage 5: set up for last stage.
            --###################################################
            -- Set first line at which we count vertical lines.
            vert_probe := sheet_whores(0) + shr (vert_div, "1");
            sheet_whores(1) := sheet_whores(0) + vert_div;
            sheet_whores(2) := sheet_whores(0) + shl (vert_div, "1");
            sheet_whores(3) := sheet_whores(0) + shl (vert_div, "1") + vert_div;
            sheet_whores(4) := sheet_whores(0) + shl (vert_div, "10");
            sheet_whores(5) := sheet_whores(8) - shl (vert_div, "1") - vert_div;
            sheet_whores(6) := sheet_whores(8) - shl (vert_div, "1");
            sheet_whores(7) := sheet_whores(8) - vert_div;
            calib_stage := "110";
         elsif calib_stage = "110" then
            --###################################################
            --## Calibration stage 6: detect xylophone keys.
            --###################################################
            if line_count = vert_probe then
               if counter = "1100" then
                  counter := "0000";
               elsif counter > "0000" then
                  counter := counter + 1;
               end if;

               -- Look for 2 black pixels followed by 8 white pixels.
               if grayscale <= black_color_thresh then
                  white_count := "0000000000";
                  black_count := black_count + 1;

                  if black_count >= "10" then
                     -- If looking for lines 0 - 7, start counter.
                     if horiz_sect < "1000" then
                        counter := "0001";
                     -- Looking for last line.
                     elsif counter > "0000" then
                        vert_lines (conv_integer (vert_sect))(conv_integer (horiz_sect)) := pixel_count;
                        horiz_sect := "0000";
                        if vert_sect = "111" then
                           calib_stage := "000";
                           vert_sect := "000";
                        else
                           vert_sect := vert_sect + 1;
                           vert_probe := vert_probe + vert_div;
                        end if;
                     end if;
                  end if;
               elsif grayscale >= white_color_thresh then
                  black_count := "0000000000";
                  white_count := white_count + 1;

                  -- If 8 white pixels detected after black:
                  if white_count > "0000000111" then
                     -- If line 0 to 7, record line.
                     if horiz_sect < "1000" and counter > "0000" then
                        vert_lines (conv_integer (vert_sect))(conv_integer (horiz_sect)) := pixel_count - counter;
                        horiz_sect := horiz_sect + 1;
                        counter := "0000";
                     elsif horiz_sect = "1000" then
                        -- Line 8's detection condition is black followed by white.
                        counter := "0001";
                     end if;
                  end if;
               end if;
               
            end if;
         end if;
      end if;
   END PROCESS;

   --################################################
   --##
   --## Notes detection.
   --##
   --################################################
   PROCESS (clk_27, hit)
   BEGIN
      if (hit > "000") then
	     --High C.
	     if mallet_hmid >= vert_lines(conv_integer(hit-1))(0) 
		       and mallet_hmid < vert_lines(conv_integer(hit-1))(1) then
			     note_hit <= "0001";
	     --B.
		   elsif mallet_hmid < vert_lines(conv_integer(hit-1))(2) then
			     note_hit <= "0010";
		   --A.
		   elsif mallet_hmid < vert_lines(conv_integer(hit-1))(3) then
			     note_hit <= "0011";
	     --G.
		   elsif mallet_hmid < vert_lines(conv_integer(hit-1))(4) then
			     note_hit <= "0100";
	     --F.
		   elsif mallet_hmid < vert_lines(conv_integer(hit-1))(5) then
			     note_hit <= "0101";
	     --E.
		   elsif mallet_hmid < vert_lines(conv_integer(hit-1))(6) then
			     note_hit <= "0110";
	     --D.
	   	 elsif mallet_hmid < vert_lines(conv_integer(hit-1))(7) then
			     note_hit <= "0111";
	     --Low C.
		   elsif mallet_hmid < vert_lines(conv_integer(hit-1))(8) then
			     note_hit <= "1000";
	     else
		       note_hit <= "0000";
	     end if;
	  end if;
   END PROCESS;   
   
   --################################################
   --##
   --## Hit detection.
   --##
   --################################################
   PROCESS (clk_27)
   BEGIN
      if (line_count = "0000000000" and pixel_count = "0000000000") then
        if mallet_width >= ball_sizes(0) and mallet_width < ball_sizes(1)
           and mallet_bot >= sheet_whores(0) and mallet_bot < sheet_whores (1)
        then
           hit <= "0001";
        elsif mallet_width >= ball_sizes(1) and mallet_width < ball_sizes(2)
              and mallet_bot >= sheet_whores(1) and mallet_bot < sheet_whores (2)
        then
           hit <= "0010";
        elsif mallet_width >= ball_sizes(2) and mallet_width < ball_sizes(3)
              and mallet_bot >= sheet_whores(2) and mallet_bot < sheet_whores (3)
        then
           hit <= "0011";
        elsif mallet_width >= ball_sizes(3) and mallet_width < ball_sizes(4)
              and mallet_bot >= sheet_whores(3) and mallet_bot < sheet_whores (4)
        then
           hit <= "0100";
        elsif mallet_width >= ball_sizes(4) and mallet_width < ball_sizes(5)
              and mallet_bot >= sheet_whores(4) and mallet_bot < sheet_whores (5)
        then
           hit <= "0101";
        elsif mallet_width >= ball_sizes(5) and mallet_width < ball_sizes(6)
              and mallet_bot >= sheet_whores(5) and mallet_bot < sheet_whores (6)
        then
           hit <= "0110";
        elsif mallet_width >= ball_sizes(6) and mallet_width < ball_sizes(7)
              and mallet_bot >= sheet_whores(6) and mallet_bot < sheet_whores (7)
        then
           hit <= "0111";
        elsif mallet_width >= ball_sizes(7) and mallet_width < ball_sizes(8)
              and mallet_bot >= sheet_whores(7) and mallet_bot < sheet_whores (8)
        then
           hit <= "1000";
        else
           hit <= "0000";
        end if;
     end if;
   END PROCESS;   
   
   --################################################
   --## Mallet size calculation.
   --################################################
   PROCESS (calibrate)
   BEGIN
      if (clk_27'EVENT and clk_27 = '1') then
         if calibrate = "0011" then
            -- Front size.
            ball_sizes(8) := mallet_width (9 downto 0);
         elsif calibrate = "0100" then
            -- Back size.
            ball_sizes(0) := mallet_width (9 downto 0);
         elsif calibrate = "0101" then
            -- Intermediate region sizes.
            ball_sizes(1) := ball_sizes(0) + shr (ball_sizes(8) - ball_sizes(0), "11");
            balL_sizes(2) := ball_sizes(0) + shr (ball_sizes(8) - ball_sizes(0), "10");
            ball_sizes(3) := ball_sizes(0) + shr (ball_sizes(8) - ball_sizes(0), "10")
                                           + shr (ball_sizes(8) - ball_sizes(0), "11");
            ball_sizes(4) := ball_sizes(0) + shr (ball_sizes(8) - ball_sizes(0), "1");
            ball_sizes(5) := ball_sizes(8) - shr (ball_sizes(8) - ball_sizes(0), "10")
                                           - shr (ball_sizes(8) - ball_sizes(0), "11");            
            balL_sizes(6) := ball_sizes(8) - shr (ball_sizes(8) - ball_sizes(0), "10");
            ball_sizes(7) := ball_sizes(8) - shr (ball_sizes(8) - ball_sizes(0), "11");
         end if;
      end if;   
   END PROCESS;
   
   --################################################
   --## Mallet detection.
   --################################################
   PROCESS (line_count, pixel_count, clk_27)
      variable consec_y : std_logic_vector (5 downto 0);
      variable consec_x : std_logic_vector (7 downto 0);
      variable consec_x_tmp : std_logic_vector (7 downto 0);
      variable left_tmp : std_logic_vector (10 downto 0);
      variable right_tmp :std_logic_vector (10 downto 0);
      variable found_bot : std_logic := '0';
      variable stage : std_logic_vector (3 downto 0) := "0000";
   BEGIN
      if (clk_27'EVENT and clk_27 = '1') then
         if line_count = "0000000000" then
            --###################################################
            --## New frame: reset variables.
            --###################################################
             stage := "0000";
             consec_x := "00000000";
             consec_x_tmp := "00000000";
             consec_y := "000000";
             left_tmp := "01011010000";
             right_tmp := "00000000000";
             found_bot := '0';
         elsif (pixel_count = "0000000000") then
            --###################################################
            --## Start of new line.
            --###################################################
            if consec_x > "0001111" then
               --###################################################
               --## Stage 0: look for top.
               --## If previous line had 15 yellow pixels in a row,
               --## and there have been 7 straight such lines, we've
               --## found the top.
               --###################################################
               if consec_y > "000111" and stage = "0000" then
                  mallet_top <= line_count - consec_y;
                  stage := "0001";
               else
                  consec_y := consec_y + 1;
               end if;
               consec_x := "00000000";
               consec_x_tmp := "00000000";
            else
               --###################################################
               --## Stage 1: look for left/right + bottom.
               --## If we broke a streak of consecutive rows with
               --## lot's of yellow pixels, we've found the bottom.
               --###################################################
               if line_count > mallet_top and found_bot = '0' and consec_y > "000100" and stage = "0001" then
                  mallet_bot <= line_count;
                  mallet_left <= left_tmp;
                  mallet_right <= right_tmp;
                  mallet_width <= right_tmp - left_tmp;
                  found_bot := '1';
                  consec_y := "000000";
                  stage := "0010";
               else
                  consec_y := "000000";
               end if;
               consec_x := "00000000";
               consec_x_tmp := "00000000";
            end if;
         elsif stage = "0010" then
            --###################################################
            --## Stage 2: Get middle.
            --## We've found left/right and top/bottom. Get the
            --## line that bisects each pair.
            --###################################################
            mallet_vmid <= mallet_top + shr (mallet_bot - mallet_top, "1");
            mallet_hmid <= mallet_left + shr (mallet_right - mallet_left, "1");
            stage := "0011";
         elsif R_int > "100000" and G_int > "100000" and B_int < shr (R_int, "1") and B_int < shr (G_int, "1") then
            --###################################################
            --## Yellow pixel found.
            --###################################################
            if stage = "0001" and consec_x_tmp > "100000" and consec_y > "111" then
               --###################################################
               --## Stage 1: look for left and right.
               --###################################################
               if (left_tmp > pixel_count - consec_x_tmp) then
                  left_tmp := pixel_count - consec_x_tmp;
               end if;
               if (right_tmp < pixel_count) then
                  right_tmp := pixel_count;
               end if;
            end if;
            consec_x_tmp := consec_x_tmp + 1;
         elsif consec_x_tmp > consec_x then
            consec_x := consec_x_tmp;
            consec_x_tmp := "00000000";
         end if;
      end if;
   end process;
   
   --################################################
   --##
   --## DISPLAY.
   --##
   --################################################
   PROCESS (grayscale, rst, clk_27, line_count, calibrate)
      variable horiz : std_logic_vector (3 downto 0) := "0000";
      variable vert : std_logic_vector (2 downto 0) := "000";
      variable zero : std_logic_vector (1 downto 0) := "00";
      variable one : std_logic_vector (1 downto 0) := "01";
      variable two : std_logic_vector (1 downto 0) := "10";
      variable three : std_logic_vector (1 downto 0) := "11";
      variable four : std_logic_vector (2 downto 0) := "100";
      variable five : std_logic_vector (2 downto 0) := "101";
      variable six : std_logic_vector (2 downto 0) := "110";
      variable seven : std_logic_vector (2 downto 0) := "111";
      variable eight : std_logic_vector (3 downto 0) := "1000";
   BEGIN
      if (clk_27'EVENT and clk_27 = '1') then
         --#####################################################
         --## Display from PPC.
         --#####################################################
         if game_mode = '1' then
            if BW = '0' then
               R <= "00000000";
               G <= "00000000";
               B <= "00000000";
            else
               R <= "11111111";
               G <= "11111111";
               B <= "11111111";
            end if;
         --#####################################################
         --## Regular display.
         --#####################################################
         elsif calibrate = "0000" then
            R <= R_int;
            G <= G_int;
            B <= B_int;
         elsif line_count = "100000" and hit > "000" then
		     --FOR TESTING PURPOSES
			      if note_hit = "0001" then 
               --High C.
			         R(7 DOWNTO 0) <= "10010101";
               G(7 DOWNTO 0) <= "10011010";
               B(7 DOWNTO 0) <= "01100010";
			      elsif note_hit = "0010" then
			         --B.
               R(7 DOWNTO 0) <= "11111111";
               G(7 DOWNTO 0) <= "00000000";
               B(7 DOWNTO 0) <= "00000000";		
			      elsif note_hit = "0011" then
			         --A.
               R(7 DOWNTO 0) <= "11111111";
               G(7 DOWNTO 0) <= "11111111";
               B(7 DOWNTO 0) <= "00000000";		
			      elsif note_hit = "0100" then
               --G.
			         R(7 DOWNTO 0) <= "11111111";
               G(7 DOWNTO 0) <= "00000000";
               B(7 DOWNTO 0) <= "11111111";		
			      elsif note_hit = "0101" then
			         --F.
               R(7 DOWNTO 0) <= "00000000";
               G(7 DOWNTO 0) <= "11111111";
               B(7 DOWNTO 0) <= "11111111";		
			      elsif note_hit = "0110" then
			         --E.
               R(7 DOWNTO 0) <= "00000000";
               G(7 DOWNTO 0) <= "11111111";
               B(7 DOWNTO 0) <= "00000000";	
			      elsif note_hit = "0111" then
			         --D.
               R(7 DOWNTO 0) <= "00000000";
               G(7 DOWNTO 0) <= "00000000";
               B(7 DOWNTO 0) <= "11111111";	
			      elsif note_hit = "1000" then
			         --Low C.
               R(7 DOWNTO 0) <= "11111100";
               G(7 DOWNTO 0) <= "11000101";
               B(7 DOWNTO 0) <= "11001111";	                 
			      else
               --Out of Bounds
			         R(7 DOWNTO 0) <= "11111111";
               G(7 DOWNTO 0) <= "11111111";
               B(7 DOWNTO 0) <= "11111111";			
			      end if;
         --#####################################################
         --##
         --##  Ball bounding box.
         --##
         --#####################################################
         elsif (line_count = mallet_top or line_count = mallet_bot or line_count = mallet_vmid)
               and pixel_count >= mallet_left and pixel_count <= mallet_right
         then
            R(7 DOWNTO 0) <= "00000000";
            G(7 DOWNTO 0) <= "11111111";
            B(7 DOWNTO 0) <= "00000000";
         elsif (line_count >= mallet_top and line_count <= mallet_bot)
                and (pixel_count = mallet_left or pixel_count = mallet_right
                     or pixel_count = mallet_hmid)
         then
            R(7 DOWNTO 0) <= "00000000";
            G(7 DOWNTO 0) <= "11111111";
            B(7 DOWNTO 0) <= "00000000";
         elsif R_int > "100000" and G_int > "100000" and B_int < shr (R_int, "1") and B_int < shr (G_int, "1") then
            -- Turn yellow pixels really yellow.
            R(7 DOWNTO 0) <= "11111111";
            G(7 DOWNTO 0) <= "11111111";
            B(7 DOWNTO 0) <= "00000000";
         -- Following is test output, for mallet location detection.
--         elsif line_count = mallet_width then  
--            R(7 DOWNTO 0) <= "11011001";
--            G(7 DOWNTO 0) <= "10001101";
--            B(7 DOWNTO 0) <= "00110101";
--         elsif line_count = ball_sizes (0) or line_count = ball_sizes (1) or line_count = ball_sizes (2) or 
--            line_count = ball_sizes (3) or line_count = ball_sizes (4) then
--            R(7 DOWNTO 0) <= "11001111";
--            G(7 DOWNTO 0) <= "11110000";
--            B(7 DOWNTO 0) <= "10111001";
         --#####################################################
         --##
         --##  Horizontal lines.
         --##
         --#####################################################
         elsif (line_count = sheet_whores(0)
                and pixel_count >= vert_lines (0)(0)
                and pixel_count <= vert_lines (0)(8))
            or (line_count = sheet_whores(1)
                and pixel_count >= vert_lines (1)(0)
                and pixel_count <= vert_lines (1)(8))
            or (line_count = sheet_whores(2)
                and pixel_count >= vert_lines (2)(0)
                and pixel_count <= vert_lines (2)(8))
            or (line_count = sheet_whores(3)
                and pixel_count >= vert_lines (3)(0)
                and pixel_count <= vert_lines (3)(8))
            or (line_count = sheet_whores(4)
                and pixel_count >= vert_lines (4)(0)
                and pixel_count <= vert_lines (4)(8))
            or (line_count = sheet_whores(5)
                and pixel_count >= vert_lines (5)(0)
                and pixel_count <= vert_lines (5)(8))
            or (line_count = sheet_whores(6)
                and pixel_count >= vert_lines (6)(0)
                and pixel_count <= vert_lines (6)(8))
            or ((line_count = sheet_whores(7) or line_count = sheet_whores(8))
                and pixel_count >= vert_lines (7)(0)
                and pixel_count <= vert_lines (7)(8))
         then
            R(7 DOWNTO 0) <= "11111111";
            G(7 DOWNTO 0) <= "11111111";
            B(7 DOWNTO 0) <= "11111111";
         --#####################################################
         --##
         --##  Vertical lines.
         --##
         --#####################################################
         elsif (line_count >= sheet_whores(0) and line_count < sheet_whores(1)
                and pixel_count = vert_lines (conv_integer(zero))(conv_integer(horiz)))
            or (line_count >= sheet_whores(1) and line_count < sheet_whores(2)
                and pixel_count = vert_lines (conv_integer(one))(conv_integer(horiz)))
            or (line_count >= sheet_whores(2) and line_count < sheet_whores(3)
                and pixel_count = vert_lines (conv_integer(two))(conv_integer(horiz)))
            or (line_count >= sheet_whores(3) and line_count < sheet_whores(4)
                and pixel_count = vert_lines (conv_integer(three))(conv_integer(horiz)))
            or (line_count >= sheet_whores(4) and line_count < sheet_whores(5)
                and pixel_count = vert_lines (conv_integer(four))(conv_integer(horiz)))
            or (line_count >= sheet_whores(5) and line_count < sheet_whores(6)
                and pixel_count = vert_lines (conv_integer(five))(conv_integer(horiz)))
            or (line_count >= sheet_whores(6) and line_count < sheet_whores(7)
                and pixel_count = vert_lines (conv_integer(six))(conv_integer(horiz)))
            or (line_count >= sheet_whores(7) and line_count <= sheet_whores(8)
                and pixel_count = vert_lines (conv_integer(seven))(conv_integer(horiz)))
         then
            R(7 DOWNTO 0) <= "11111111";
            G(7 DOWNTO 0) <= "11111111";
            B(7 DOWNTO 0) <= "11111111";
            if horiz = "1000" then
               horiz := "0000";
            else
               horiz := horiz + 1;
            end if;
         --#####################################################
         --##
         --##  Remaining output.
         --##
         --#####################################################
         elsif grayscale >= white_color_thresh then
            R(7 DOWNTO 0) <= "11111111";
            G(7 DOWNTO 0) <= "00000000";
            B(7 DOWNTO 0) <= "00000000";
         elsif grayscale <= black_color_thresh then
            R(7 DOWNTO 0) <= "00000000";
            G(7 DOWNTO 0) <= "00000000";
            B(7 DOWNTO 0) <= "11111111";
         else
            R(7 DOWNTO 0) <= R_int(7 DOWNTO 0);
            G(7 DOWNTO 0) <= G_int(7 DOWNTO 0);
            B(7 DOWNTO 0) <= B_int(7 DOWNTO 0);
         end if;
      end if;
   END PROCESS;


   NEG_EDGE_DETECT_i : NEG_EDGE_DETECT 
      PORT MAP (
         clk => clk_27,
         data_in => Fo_444,
         reset => rst,
         one_shot_out => one_shot_out);   
   
   SPECIAL_SVGA_TIMING_GENERATION_tmp : SPECIAL_SVGA_TIMING_GENERATION 
      PORT MAP (
         pixel_clock => clk_27,
         reset => reset_timing_gen,
         h_synch_delay => h_synch_delay,
         v_synch_delay => v_synch_delay,
         comp_synch => comp_synch,
         blank => blank,
         char_line_count => char_line_count,
         char_address => char_address,
         char_pixel => char_pixel,
         pixel_count => pixel_count,
		 row_count => line_count);   
   
   PIPE_LINE_DELAY_tmp : PIPE_LINE_DELAY 
      PORT MAP (
         clk => clk_27,
         rst => rst,
         hsync_in => hsync_in,
         vsync_in => vsync_in,
         blank_in => blank_in,
         comp_sync_in => comp_sync_in,
         hsync_out => hsync_out,
         vsync_out => vsync_out,
         blank_out => blank_out,
         comp_sync_out => comp_synch_out);   
   
END behavioral;
