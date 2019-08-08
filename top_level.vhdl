--
-- Copyright (C) 2009-2012 Chris McClelland
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
	port(
		-- FX2LP interface ---------------------------------------------------------------------------
		fx2Clk_in      : in    std_logic;                    -- 48MHz clock from FX2LP
		fx2Addr_out    : out   std_logic_vector(1 downto 0); -- select FIFO: "00" for EP2OUT, "10" for EP6IN
		fx2Data_io     : inout std_logic_vector(7 downto 0); -- 8-bit data to/from FX2LP

		-- When EP2OUT selected:
		fx2Read_out    : out   std_logic;                    -- asserted (active-low) when reading from FX2LP
		fx2OE_out      : out   std_logic;                    -- asserted (active-low) to tell FX2LP to drive bus
		fx2GotData_in  : in    std_logic;                    -- asserted (active-high) when FX2LP has data for us

		-- When EP6IN selected:
		fx2Write_out   : out   std_logic;                    -- asserted (active-low) when writing to FX2LP
		fx2GotRoom_in  : in    std_logic;                    -- asserted (active-high) when FX2LP has room for more data from us
		fx2PktEnd_out  : out   std_logic;                    -- asserted (active-low) when a host read needs to be committed early

		-- Onboard peripherals -----------------------------------------------------------------------
		sseg_out       : out   std_logic_vector(7 downto 0); -- seven-segment display cathodes (one for each segment)
		anode_out      : out   std_logic_vector(3 downto 0); -- seven-segment display anodes (one for each digit)
		led_out        : out   std_logic_vector(7 downto 0); -- eight LEDs
		sw_in          : in    std_logic_vector(7 downto 0);  -- eight switches
		reset :in std_logic
	);
end entity;

architecture structural of top_level is

	-- Channel read/write interface -----------------------------------------------------------------
	signal chanAddr  : std_logic_vector(6 downto 0);  -- the selected channel (0-127)
	-- Host >> FPGA pipe:
	signal h2fData   : std_logic_vector(7 downto 0);  -- data lines used when the host writes to a channel
	signal h2fValid  : std_logic;                     -- '1' means "on the next clock rising edge, please accept the data on h2fData"
	signal h2fReady  : std_logic;                     -- channel logic can drive this low to say "I'm not ready for more data yet"

	-- Host << FPGA pipe:
	signal f2hData   : std_logic_vector(7 downto 0);  -- data lines used when the host reads from a channel
	signal f2hValid  : std_logic;                     -- channel logic can drive this low to say "I don't have data ready for you"
	signal f2hReady  : std_logic;                     -- '1' means "on the next clock rising edge, put your next byte of data on f2hData"
	-- ----------------------------------------------------------------------------------------------
	
	-- Needed so that the comm_fpga_fx2 module can drive both fx2Read_out and fx2OE_out
	signal fx2Read   : std_logic;

	-- Reset signal so host can delay startup
	signal fx2Reset  : std_logic;
	signal debounced_reset : std_logic;
        signal global_c : std_logic_vector(2 down to 0) := (others => '0');
	signal timer3_us11 : unsigned(30 downto 0) := (others => '0');
	signal reset3_1 : std_logic;
	signal out1 : std_logic_vector(7 down to 0);
	signal out2 : std_logic_vector(7 down to 0);
	signal out3 : std_logic_vector(7 down to 0);
	signal out4 : std_logic_vector(7 down to 0);
	signal out5 : std_logic_vector(7 down to 0);
	signal out6 : std_logic_vector(7 down to 0);
	signal out7 : std_logic_vector(7 down to 0);
	signal out8 : std_logic_vector(7 down to 0);


	function to_sl_2(condition : BOOLEAN) return STD_LOGIC is
	begin
	    if condition then
		return '1';
	    else
		return '0';
	    end if;
	end function;

	function To_Std_Logic_2(L: BOOLEAN) return std_ulogic is
	begin
	if L then
	return('1');
	else
	return('0');
	end if;
	end function To_Std_Logic_2;

begin
	debouncer5 : entity work.debouncer
              port map (clk => fx2Clk_in,
                        button => reset,
                        button_deb => debounced_reset);
	-- CommFPGA module
	fx2Read_out <= fx2Read;
	fx2OE_out <= fx2Read;
	fx2Addr_out(0) <=  -- So fx2Addr_out(1)='0' selects EP2OUT, fx2Addr_out(1)='1' selects EP6IN
		'0' when fx2Reset = '0'
		else 'Z';
	comm_fpga_fx2 : entity work.comm_fpga_fx2
		port map(
			clk_in         => fx2Clk_in,
			reset_in       => '0',
			reset_out      => fx2Reset,
			
			-- FX2LP interface
			fx2FifoSel_out => fx2Addr_out(1),
			fx2Data_io     => fx2Data_io,
			fx2Read_out    => fx2Read,
			fx2GotData_in  => fx2GotData_in,
			fx2Write_out   => fx2Write_out,
			fx2GotRoom_in  => fx2GotRoom_in,
			fx2PktEnd_out  => fx2PktEnd_out,

			-- DVR interface -> Connects to application module
			chanAddr_out   => chanAddr,
			h2fData_out    => h2fData,
			h2fValid_out   => h2fValid,
			h2fReady_in    => h2fReady,
			f2hData_in     => f2hData,
			f2hValid_in    => f2hValid,
			f2hReady_out   => f2hReady
		);

	-- Switches & LEDs application
	swled_app : entity work.swled
		port map(
			clk_in       => fx2Clk_in,
			reset_in     => debounced_reset,
			
			-- DVR interface -> Connects to comm_fpga module
			chanAddr_in  => chanAddr,
			h2fData_in   => h2fData,
			h2fValid_in  => h2fValid,
			h2fReady_out => h2fReady,
			f2hData_out  => f2hData,
			f2hValid_out => f2hValid,
			f2hReady_in  => f2hReady,
                        output1 => out1,
			output2 => out2,
			output3 => out3,
			output4 => out4,
			output5 => out5,
			output6 => out6,
			output7 => out7,
			output8 => out8,			


			-- External interface
			sseg_out     => sseg_out,
			anode_out    => anode_out,
			led_out      => led_out,
			sw_in        => sw_in
		);

                tick3 <= to_sl(timer3_us = 3*48*1000*1000 - 1);
		reset3 <= tick3 or reset_in or To_Std_Logic_2(global_c = "000");

                process(clk_in,reset_in)
		begin
		
                if(reset_in = '1') then

		global_c <= "000";
                led_out <= "11111111";
		timer3_us11 <= (others => '0');
		
		elsif(rising_edge(clk_in)) then

			if (reset3_1 = '1' ) then
			    timer3_us11 <= (others => '0');
			else
			    timer3_us11 <= timer3_us11 + 1;
			end if;

			if (global_c="000") then --reset state
			 	if(tick3 = '1')  then
					led_out <= "00000000";
					global_c <= "001";
				end if;
			elsif

                end if;

                



	
                end       



end architecture;
