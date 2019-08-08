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
architecture rtl of swled is
	component decrypter
	Port ( clock : in  STD_LOGIC;
           K : in  STD_LOGIC_VECTOR (31 downto 0);
           C : in  STD_LOGIC_VECTOR (31 downto 0);
           P : out  STD_LOGIC_VECTOR (31 downto 0);
           reset : in  STD_LOGIC;
			  done : out STD_LOGIC;
           enable : in  STD_LOGIC);
	end component;     
	component encrypter
	Port ( clock : in  STD_LOGIC;
           K : in  STD_LOGIC_VECTOR (31 downto 0);
           P : in  STD_LOGIC_VECTOR (31 downto 0);
           C : out  STD_LOGIC_VECTOR (31 downto 0);
           reset : in  STD_LOGIC;
			  done : out STD_LOGIC;
           enable : in  STD_LOGIC);
	end component;
	-- Flags for display on the 7-seg decimal points
	signal flags                   : std_logic_vector(3 downto 0);

	-- Registers implementing the channels
	--signal checksum, checksum_next : std_logic_vector(15 downto 0) := (others => '0');
	--signal reg0, reg0_next         : std_logic_vector(7 downto 0)  := (others => '1');
	signal timer16_us : unsigned(30 downto 0) := (others => '0');
	signal timer1_us,timer3_us : unsigned(30 downto 0) := (others => '0');
	signal timerto_us : unsigned(34 downto 0) := (others => '0');
	signal tick16 : std_logic;
	signal tick1,tick3  : std_logic;
	signal reset_timeout,tick_timeout,tcond,disp1  : std_logic := '0';
	signal reset16 : std_logic;
	signal reset1,reset3 : std_logic;
	signal input_rec : std_logic_vector(31 downto 0) := (others => '0');
   	signal inp : std_logic_vector(7 downto 0) := (others => '0');
	signal inp1  : std_logic_vector(7 downto 0)  := (others => '0');
	signal inp2  : std_logic_vector(7 downto 0)  := (others => '0');
	signal inp3  : std_logic_vector(7 downto 0)  := (others => '0');
	signal inp4  : std_logic_vector(7 downto 0)  := (others => '0');
	signal inp5  : std_logic_vector(7 downto 0)  := (others => '0');
	signal inp6  : std_logic_vector(7 downto 0)  := (others => '0');
	signal inp7  : std_logic_vector(7 downto 0)  := (others => '0');
	signal inp8  : std_logic_vector(7 downto 0)  := (others => '0');
	signal inpB1,outB1 : std_logic_vector(31 downto 0)  := (others => '0');
	signal d1 : std_logic := '0';
	signal counter_next    : std_logic_vector(1 downto 0) := "00";
	signal gc : std_logic_vector(5 downto 0):= (others => '0');
	signal edec : std_logic := '0';
	signal eenc : std_logic := '0'; 
	--signal output_next : std_logic_vector(7 downto 0) := (others => '0');
	signal TrackExists,TrackOK : std_logic;
    signal Direction,DirectionOpp, NextSignal: std_logic_vector(2 downto 0);
    signal counter1_next : std_logic_vector(3 downto 0) := (others => '0');
    signal dispchange : std_logic_vector(1 downto 0) := (others => '0');
    signal K2 : std_logic_vector(31 downto 0)  := "10000000010000000000100010010000";
    signal read_count : std_logic_vector(1 downto 0) := "00";
    --signal write_count :std_logic_vector(1 downto 0) := "00";
    signal coordinates : std_logic_vector(31 downto 0) := "00000000000000000000000000100010";
    signal ack1 : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";
    signal ack2 : std_logic_vector(31 downto 0) := "00000000000000000000000000000001";
    --signal coord_rec : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal enci,enco : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal readD : std_logic_vector(7 downto 0) := (others => '0');
    signal Init : STD_LOGIC := '1';
    signal valid : STD_LOGIC := '0';
    --signal isinc1 : std_logic := '0';
    --signal isinc2 : std_logic := '0';
    --signal doneinc1 : std_logic := '0';
    --signal doneinc2 : std_logic := '0';
    signal reset_enc,reset_dec : std_logic := '0';
function to_sl(condition : BOOLEAN) return STD_LOGIC is
begin
    if condition then
        return '1';
    else
        return '0';
    end if;
end function;

function To_Std_Logic(L: BOOLEAN) return std_ulogic is
begin
if L then
return('1');
else
return('0');
end if;
end function To_Std_Logic;
begin                                                                 --BEGIN_SNIPPET(registers)
	-- Infer registers
	encrypt1: encrypter
              port map (clock => clk_in,
                        reset => reset_enc,
                        C => enco,
                        enable => eenc,
                        P => enci,
                        done => valid,
                        K => k2);
    decrypt1: decrypter
              port map (clock => clk_in,
                        reset => reset_dec,
                        C => input_rec,
                        enable => edec,
                        P => outB1,
                        done => d1,
                        K => k2);
        

        done_1 <= '0';

	process(clk_in,reset_in)
	begin
             if(done_1 = '0') then
			if ( reset_in = '1' ) then
				led_out <= "11111111";
				timer16_us <= (others => '0');
				timer1_us <= (others => '0');
				timer3_us <= (others => '0');
				timerto_us <= (others => '0');
				--tick16 <= '0';
				--tick1 <='0';
				--tick3 <='0';
				--reset_timeout <= '0';
				--tick_timeout <= '0';
				tcond <= '0';
				disp1 <= '0';
				--reset16 <= '1';
				--reset1 <= '1';
				--reset3 <='1';
				input_rec <= (others => '0');
			   	inp <= (others => '0');
				inp1  <= (others => '0');
				inp2  <= (others => '0');
				inp3  <= (others => '0');
				inp4  <= (others => '0');
				inp5  <= (others => '0');
				inp6  <= (others => '0');
				inp7  <= (others => '0');
				inp8  <= (others => '0');
				inpB1 <= (others => '0');
				--outB1 <= (others => '0');
				--d1 <= '0';
				counter_next <= "00";
				gc <= "000000";
				done_1 <= '1';
				edec <= '0';
				eenc <= '0';
			    counter1_next <= (others => '0');
			    dispchange <= (others => '0');
			    K2 <= "10000000010000000000100010010000";
			    read_count <= "00";
			    --signal write_count :std_logic_vector(1 downto 0) := "00";
			    coordinates <= "00000000000000000000000000100010";
			    ack1 <= "00000000000000000000000000000001";
			    ack2 <= "00000000000000000000000000000001";
			    --signal coord_rec : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
			    enci <= "00000000000000000000000000000000";
			    --enco <= "00000000000000000000000000000000";
			    readD <= (others => '0');
			    Init <= '1';
			    --valid <= '0';
			elsif(rising_edge(clk_in)) then
				if ( reset16 = '1' ) then
					timer16_us <= (others => '0');
				else
					timer16_us <= timer16_us + 1;
				end if;
				if ( reset3 = '1' ) then
					timer3_us <= (others => '0');
				else
					timer3_us <= timer3_us + 1;
				end if;
				if ( reset1 = '1' ) then
					timer1_us <= (others => '0');
				else
					timer1_us <= timer1_us + 1;
				end if;
				if ( reset_timeout = '1' ) then
					timerto_us <= (others => '0');
				else
					timerto_us <= timerto_us + 1;
				end if;
				if ((gc = "000000") or (gc = "000010") or (gc = "000101") or (gc = "000111")) then
					--led_out<="11"&gc;
					f2hValid_out <= '1';
					if (gc = "000000") then
						reset_enc <= '0';
						enci <= coordinates;
						eenc <='1';
						Init <= '1';
					elsif ((gc = "000010") or (gc = "000101") or (gc = "000111")) then
						reset_enc <= '0';
						enci <= ack1;
						eenc <= '1';
						Init <= '1';
						--led_out <= "10"&gc;
					end if;
					if ((Init = '1') and (valid = '1')) then
						readD <= enco(31 downto 24);
						Init <= '0';
					end if;
					if(f2hReady_in = '1' and chanAddr_in = "0000010") then
						read_count <= std_logic_vector(unsigned(read_count)+1);
						--led_out <= std_logic_vector(to_unsigned(31-(8*to_integer(unsigned(read_count))),8));
						if(read_count = "00") then
							readD <= enco(23 downto 16);
						elsif (read_count = "01") then
							readD <= enco(15 downto 8);
						elsif (read_count = "10") then
							readD <= enco(7 downto 0);
						elsif (read_count = "11") then
							readD <= enco(31 downto 24);
							reset_enc <= '1';
							eenc <= '0';
							gc <= std_logic_vector(unsigned(gc)+1);
							tcond <= '1';
						end if;
					end if;
					--led_out<="11"&gc;
				elsif ((gc = "000001") or (gc = "000011") or (gc = "000100") or (gc = "000110") or (gc = "001000")) then
					--led_out<="11"&gc;
					--f2hValid_out <= '0';
					h2fready_out <='1';
					if ((tick16 /= '1' ) and chanAddr_in = "0000011" and h2fValid_in = '1') then
						if (counter_next = "00") then input_rec(31 downto 24) <= h2fData_in;
						elsif (counter_next = "01") then input_rec(23 downto 16) <= h2fData_in;
						elsif (counter_next = "10") then input_rec(15 downto 8) <= h2fData_in;
						elsif (counter_next = "11") then 
							input_rec(7 downto 0) <= h2fData_in;
							edec <= '1';
							reset_dec <= '0';
						end if;
						 --led_out<=h2fData_in;
						counter_next <= std_logic_vector(unsigned(counter_next)+1);
					end if;
					if ((gc = "000001") and (tick_timeout = '1' or (d1 = '1'))) then
						--led_out<=outB1(7 downto 0);
						if(outB1(31 downto 0) = coordinates(31 downto 0)) then
							gc <= std_logic_vector(unsigned(gc)+1);
							tcond <= '0';
						elsif (tick_timeout = '1') then
							tcond<='0';
							gc <= "000000";
						end if;
						--led_out <= "10"&gc;
						edec <= '0';
						reset_dec <= '1';
					elsif (((gc = "000011") or (gc = "001000"))and (tick_timeout = '1' or (d1 = '1'))) then
						if(outB1(31 downto 0) = ack2(31 downto 0)) then
							gc <= std_logic_vector(unsigned(gc)+1);
							tcond <= '0';
						elsif (tick_timeout = '1') then
							tcond<='0';
							gc <= "000000";
						end if;
						--led_out <= "10"&gc;
						edec <= '0';
						reset_dec <= '1';
						--led_out <= "10"&gc;
					elsif ((gc = "000100") and (d1 = '1')) then
						inp1 <= outB1(31 downto 24);
						output1 <= outB1(31 downto 24);
						inp2 <= outB1(23 downto 16);
						output2 <= outB1(23 downto 16);
						inp3 <= outB1(15 downto 8);
						output3 <= outB1(15 downto 8);
						inp4 <= outB1(7 downto 0);
						output4 <= outB1(7 downto 0);
						gc <= std_logic_vector(unsigned(gc)+1);
						edec <= '0';
						reset_dec <= '1';
						--led_out <= "10"&gc;
					elsif ((gc = "000110") and (d1 = '1')) then
						inp5 <= outB1(31 downto 24);
				                output5 <= outB1(31 downto 24);
						inp6 <= outB1(23 downto 16);
						output6 <= outB1(23 downto 16);
						inp7 <= outB1(15 downto 8);
						output7 <= outB1(15 downto 8);
						inp8 <= outB1(7 downto 0);
						output8 <= outB1(7 downto 0);						
						gc <= std_logic_vector(unsigned(gc)+1);
						edec <= '0';
						reset_dec <= '1';
						--led_out <= "10"&gc;
					end if;
					--reg0 <=reg0_next;
					--led_out<="11"&gc;
				elsif ((gc="001001")) then
					if (tick3='1' and tick16 = '0' and gc="001001" and counter1_next /= "1010") then
						counter1_next <= 
						std_logic_vector(unsigned(counter1_next)+1);
						--led_out <= "00000011";
		            elsif (gc="001001"and tick16 = '0') then 
						counter1_next <= counter1_next;
						--led_out <= "00000001";
					elsif (tick16 = '1') then
					 	 gc <= "000000";
					 	 counter1_next <= "0000";
						 done_1 <= '1';
					end if;
				  	if (counter1_next = "0000" and tick3 ='1') then
				  		inp <= inp1;
				  		--led_out <= "00000000";
			     	elsif (counter1_next = "0001" and tick3 ='1') then
			      		inp <= inp2;
			      		--led_out <= "00000001";
		            elsif(counter1_next = "0010" and tick3 ='1') then
		              inp <= inp3;
		              --led_out <= "00000010";
		            elsif(counter1_next = "0011" and tick3 ='1') then
		              inp <= inp4;
		              --led_out <= "00000011";
		            elsif(counter1_next = "0100" and tick3 ='1') then
		              inp <= inp5;
		              --led_out <= "00000100";
		            elsif(counter1_next = "0101" and tick3 ='1') then
		              inp <= inp6;
		              --led_out <= "00000101";
		            elsif(counter1_next = "0110" and tick3 ='1') then
		              inp <= inp7;
		              --led_out <= "00000110";
		            elsif(counter1_next = "0111" and tick3 ='1') then
		              inp <= inp8;
		              --led_out <= "00000111";
		            else inp<=inp;
		            end if;
		            if (counter1_next > "0000" and tick3='1' and counter1_next < "1001") then
		            	TrackExists <= inp(7);
		            end if;
		            if (counter1_next > "0000" and tick3='1' and counter1_next < "1001") then
		            	TrackOk <= inp(6);
		            end if;
		            if (counter1_next > "0000" and tick3='1' and counter1_next < "1001") then
		            	Direction <= inp(5 downto 3);
		            	DirectionOpp <= std_logic_vector(unsigned(inp(5 downto 3))+4);
		            end if;	
		            if (counter1_next > "0000" and tick3='1' and counter1_next < "1001") then
		            	NextSignal <= inp(2 downto 0);
		            end if;
		            if(h2fValid_in = '0'and counter1_next < "1010" and gc="001001" and counter1_next > "0001") then
		            	if(TrackExists = '0' or TrackOk = '0' or sw_in(to_integer(unsigned(Direction))) = '0') then
		            		led_out <= "10000"&Direction;
		            	elsif (sw_in(to_integer(unsigned(Direction))) = '1') then
		            		if (sw_in(to_integer(unsigned(DirectionOpp))) = '0') then
		            			led_out <= "00100"&Direction;
		            		else
		            			if(Direction < DirectionOpp) then
		            				led_out <= "10000"&Direction;
		            			else
		            				if(tick3 = '1') then
		            					dispchange <= "00";
		            				elsif (tick1 = '1') then
		            					dispchange<=std_logic_vector(unsigned(dispchange)+1);
		            				end if;
		            				if(dispchange <= "00") then
		            					disp1<='1';
		            					led_out<= "00100"&Direction;
		            				elsif (dispchange = "01") then
		            					--led_out <= TrackExists&TrackOk&sw_in(to_integer(unsigned(Direction)))&sw_in(to_integer(unsigned(DirectionOpp)))&reset1&reset2&disp1&disp2;
		            					led_out <="01000"&Direction;
		            				elsif (dispchange = "10") then
		            					disp1<='0';
		            					--led_out <= TrackExists&TrackOk&sw_in(to_integer(unsigned(Direction)))&sw_in(to_integer(unsigned(DirectionOpp)))&reset1&reset2&disp1&disp2;
		            					led_out <= "10000"&Direction;
		            				end if;		            					
		            			end if;		            			
		            		end if ;
		            	end if;
		            end if;
					

				--elsif ((gc="001010")) then --reset state
				--	if(tick3 = '1')  then
				--		led_out <= "00000000";
				--		gc <= "000000";
				--	end if;
				end if ;

			end if;

         elsif (done_2 = '0' and enable_2 = '1') then
	 
         ---Added S3 here 
         

         end if;


	end process;
	tick3 <= to_sl(timer3_us = 3*48*1000*1000 - 1);
	tick1 <= to_sl(timer1_us = 48*1000*1000 - 1);
	--tick2 <= to_sl(timer2_us = 2*48*1000*1000 - 1);
	tick16 <= to_sl(timer16_us = 32*48*1000*1000 - 1);
	tick_timeout <= to_sl(timerto_us = 256*48*1000*1000 - 1);
	reset16 <= tick16 or reset_in or To_Std_Logic(gc /= "001001");
	reset3 <= tick3 or reset_in or To_Std_Logic(((gc /= "001001") and (gc /= "001010")));
	reset1 <= tick1 or reset_in or To_Std_Logic((disp1 /= '1'));
	--reset2 <= tick2 or reset_in or To_Std_Logic((disp2 /= '1'));
	reset_timeout <= tick_timeout or reset_in or To_Std_Logic((tcond /= '1'));
	-- Drive register inputs for each channel when the host is writing
	--reg0_next <=
	--	h2fData_in when chanAddr_in = "0000001" and h2fValid_in = '1' and gc < "001001"
	--	else reg0;
	--led_out<=tcond&reset_timeout&gc;
	--led_out <= "00"&sw_in(5 downto 0);
	with chanAddr_in select f2hData_out <=
		readD when "0000010",
		--checksum(15 downto 8) when "0000001",
		--checksum(7 downto 0)  when "0000010",
		x"00" when others;
	flags <= "00" & f2hReady_in & reset_in;
		seven_seg : entity work.seven_seg
			port map(
				clk_in     => clk_in,
				data_in    =>  (others => '0'),
				dots_in    => flags,
				segs_out   => sseg_out,
				anodes_out => anode_out
			);
end architecture;
