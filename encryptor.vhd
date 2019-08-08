----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:12:16 01/23/2018 
-- Design Name: 
-- Module Name:    encrypter - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encrypter is
    Port ( clock : in  STD_LOGIC;
           K : in  STD_LOGIC_VECTOR (31 downto 0);
           P : in  STD_LOGIC_VECTOR (31 downto 0);
           C : out  STD_LOGIC_VECTOR (31 downto 0);
           reset : in  STD_LOGIC;
			  done : out STD_LOGIC;
           enable : in  STD_LOGIC);
end encrypter;

architecture Behavioral of encrypter is
--Temporary signal to rotate key
signal K2 : STD_LOGIC_VECTOR (31 downto 0);
--Required 4 bit T signal
signal T : STD_LOGIC_VECTOR (3 downto 0);
--Counter to differentiate between initialization/loop/other
signal instantiate : STD_LOGIC_VECTOR (5 downto 0);
--Signal for processing C
signal C2 : STD_LOGIC_VECTOR (31 downto 0);
begin
    process(clock, reset, enable)
	 begin
		if (reset = '1') then
		   -- Reset values
			C <= "00000000000000000000000000000000";
			C2 <= "00000000000000000000000000000000";
			K2 <= "00000000000000000000000000000000";
			instantiate <= "000000";
			done <= '0';
			T <= "0000";
		elsif (clock'event and clock = '1' and enable = '1') then
       if (instantiate = "000000") then
		     --Initialize all the required signals
			  done <= '0';
		     C2 <= P;
	        K2 <= K;
	        T(3) <= K(31) XOR K(27) XOR K(23) XOR K(19) XOR K(15) XOR K(11) XOR K(7) XOR K(3);
           T(2) <= K(30) XOR K(26) XOR K(22) XOR K(18) XOR K(14) XOR K(10) XOR K(6) XOR K(2);
	        T(1) <= K(29) XOR K(25) XOR K(21) XOR K(17) XOR K(13) XOR K(9) XOR K(5) XOR K(1);
	        T(0) <= K(28) XOR K(24) XOR K(20) XOR K(16) XOR K(12) XOR K(8) XOR K(4) XOR K(0);       
		     instantiate <= "000001";
		 elsif (instantiate = "100000" OR instantiate < "100000") then 
		       --Check if bit is 1 so determine number of loop iterations
		       if (K2(0) = '1') then
				    -- Algorithm steps 
			       C2(31 downto 28) <= C2(31 downto 28) XOR T;
                C2(27 downto 24) <= C2(27 downto 24) XOR T;
                C2(23 downto 20) <= C2(23 downto 20) XOR T;
                C2(19 downto 16) <= C2(19 downto 16) XOR T;
                C2(15 downto 12) <= C2(15 downto 12) XOR T;
                C2(11 downto 8) <= C2(11 downto 8) XOR T;
                C2(7 downto 4) <= C2(7 downto 4) XOR T;
                C2(3 downto 0) <= C2(3 downto 0) XOR T;			  
			       T <= T+1;
			    end if;
			       -- Increment instantiate to find number of iterations
		 			 instantiate <= instantiate+1;
					 -- Right shift the key stored temporarily in K2
					 K2 <= STD_LOGIC_VECTOR(shift_right(unsigned(K2),1));
		 end if;			  
		 C <= C2;
		 if (instantiate = "100001") then
			done <= '1';
		 end if;
		end if;
			
	 end process;

end Behavioral;