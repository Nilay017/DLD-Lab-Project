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

entity swled is
	port(
		clk_in       : in  std_logic;
		reset_in     : in  std_logic;

		-- DVR interface -----------------------------------------------------------------------------
		chanAddr_in  : in  std_logic_vector(6 downto 0);  -- the selected channel (0-127)

		-- Host >> FPGA pipe:
		h2fData_in   : in  std_logic_vector(7 downto 0);  -- data lines used when the host writes to a channel
		h2fValid_in  : in  std_logic;                     -- '1' means "on the next clock rising edge, please accept the data on h2fData"
		h2fReady_out : out std_logic;                     -- channel logic can drive this low to say "I'm not ready for more data yet"

		-- Host << FPGA pipe:
		f2hData_out  : out std_logic_vector(7 downto 0);  -- data lines used when the host reads from a channel
		f2hValid_out : out std_logic;                     -- channel logic can drive this low to say "I don't have data ready for you"
		f2hReady_in  : in  std_logic;                     -- '1' means "on the next clock rising edge, put your next byte of data on f2hData"

		-- Peripheral interface ----------------------------------------------------------------------
		sseg_out       : out   std_logic_vector(7 downto 0); -- seven-segment display cathodes (one for each segment)
		anode_out      : out   std_logic_vector(3 downto 0); -- seven-segment display anodes (one for each digit)
		led_out        : out   std_logic_vector(7 downto 0); -- eight LEDs
		sw_in          : in    std_logic_vector(7 downto 0)  -- eight switches

                -----------------------------------------------------------------------------------------------
                output1 : out std_logic_vector(7 downto 0); -- name is self explanatory
		output2 : out std_logic_vector(7 downto 0); -- name is self explanatory
		output3 : out std_logic_vector(7 downto 0); -- name is self explanatory
	        output4 : out std_logic_vector(7 downto 0); -- name is self explanatory
		output5 : out std_logic_vector(7 downto 0); -- name is self explanatory
		output6 : out std_logic_vector(7 downto 0); -- name is self explanatory
		output7 : out std_logic_vector(7 downto 0); -- name is self explanatory
		output8 : out std_logic_vector(7 downto 0); -- name is self explanatory
				
                ------------------------------------------------------------------------------------------------
                enable_1 : in std_logic; ----first mode of operation
		enable_2 : in std_logic; ----first mode of operation
		done_1 : out std_logic; ----first mode of operation
		done_2 : out std_logic; ----first mode of operation

               
			



	);
end entity;
