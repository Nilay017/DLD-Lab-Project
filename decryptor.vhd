----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:19:03 01/23/2018 
-- Design Name: 
-- Module Name:    decrypter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decrypter is
    Port ( clock : in  STD_LOGIC;
           K : in  STD_LOGIC_VECTOR (31 downto 0);
           C : in  STD_LOGIC_VECTOR (31 downto 0);
           P : out  STD_LOGIC_VECTOR (31 downto 0);
           reset : in  STD_LOGIC;
	   done : out STD_LOGIC;
           enable : in  STD_LOGIC);
end decrypter;

architecture Behavioral of decrypter is
	signal T : STD_LOGIC_VECTOR(3 downto 0);
	-- Required for algorithm
	signal instantiate : STD_LOGIC_VECTOR(5 downto 0);
	-- Works as counter for decryption cycles
	signal P2 : STD_LOGIC_VECTOR(31 downto 0);
	--  instantiate plaintext for the decryption schedule
	signal count : STD_LOGIC_VECTOR(5 downto 0);
	
	signal count2 : STD_LOGIC_VECTOR(5 downto 0);
begin
	process(clock, reset, enable)
	 begin
	 -- resetting the schedule 
		if (reset = '1') then
			P <= "00000000000000000000000000000000";
			P2 <= "00000000000000000000000000000000";
			instantiate <= "000000";
			T <= "0000";
			count <= "000000";
			done <= '0';
	 -- schedule progresses	 
		elsif (clock'event and clock = '1' and enable = '1') then
	 -- instantiates after enable is 1 for first time
			if (instantiate = "000000") then
				done <= '0';
				P2 <= C;
				T <= 15 + (K(31 downto 28) xor K(27 downto 24) xor K(23 downto 20) xor K(19 downto 16) xor K(15 downto 12) xor K(11 downto 8) xor K(7 downto 4) xor K(3 downto 0));
				instantiate <= "000001";
				count <= ("00000" & not(K(0))) + ("00000" & not(K(1))) + ("00000" & not(K(2))) + ("00000" & not(K(3))) + ("00000" & not(K(4))) + ("00000" & not(K(5))) + ("00000" & not(K(6))) +
	("00000" & not(K(7))) + ("00000" & not(K(8))) + ("00000" & not(K(9))) + ("00000" & not(K(10))) + ("00000" & not(K(11))) + ("00000" & not(K(12))) + ("00000" & not(K(13))) +
	("00000" & not(K(14))) + ("00000" & not(K(15))) + ("00000" & not(K(16))) + ("00000" & not(K(17))) + ("00000" & not(K(18))) + ("00000" & not(K(19))) + ("00000" & not(K(20))) +
	("00000" & not(K(21))) + ("00000" & not(K(22))) + ("00000" & not(K(23))) + ("00000" & not(K(24))) + ("00000" & not(K(25))) + ("00000" & not(K(26))) + ("00000" & not(K(27))) +
	("00000" & not(K(28))) + ("00000" & not(K(29))) + ("00000" & not(K(30))) + ("00000" & not(K(31)));
				count2 <= ("000001") + ("00000" & not(K(0))) + ("00000" & not(K(1))) + ("00000" & not(K(2))) + ("00000" & not(K(3))) + ("00000" & not(K(4))) + ("00000" & not(K(5))) + ("00000" & not(K(6))) +
	("00000" & not(K(7))) + ("00000" & not(K(8))) + ("00000" & not(K(9))) + ("00000" & not(K(10))) + ("00000" & not(K(11))) + ("00000" & not(K(12))) + ("00000" & not(K(13))) +
	("00000" & not(K(14))) + ("00000" & not(K(15))) + ("00000" & not(K(16))) + ("00000" & not(K(17))) + ("00000" & not(K(18))) + ("00000" & not(K(19))) + ("00000" & not(K(20))) +
	("00000" & not(K(21))) + ("00000" & not(K(22))) + ("00000" & not(K(23))) + ("00000" & not(K(24))) + ("00000" & not(K(25))) + ("00000" & not(K(26))) + ("00000" & not(K(27))) +
	("00000" & not(K(28))) + ("00000" & not(K(29))) + ("00000" & not(K(30))) + ("00000" & not(K(31)));
			elsif((instantiate = count) or (instantiate < count )) then
				P2(31 downto 28) <= P2(31 downto 28) xor T;
				P2(27 downto 24) <= P2(27 downto 24) xor T;
				P2(23 downto 20) <= P2(23 downto 20) xor T;
				P2(19 downto 16) <= P2(19 downto 16) xor T;
				P2(15 downto 12) <= P2(15 downto 12) xor T;
				P2(11 downto 8) <= P2(11 downto 8) xor T;
				P2(7 downto 4) <= P2(7 downto 4) xor T;
				P2(3 downto 0) <= P2(3 downto 0) xor T;
				T <= T + 15;
				instantiate <= instantiate + 1;
			elsif(instantiate = count2) then
			-- assigned output
				P <= P2;
				instantiate <= instantiate + 1;
			else 
				done <= '1';
		   end if;
		end if;	
	 end process;

end Behavioral;
