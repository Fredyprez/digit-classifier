----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2026 02:52:51 PM
-- Design Name: 
-- Module Name: accumulation - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity accumulation is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           pixel : in STD_LOGIC;
           weight : in STD_LOGIC_VECTOR (7 downto 0);
           accumulated : out STD_LOGIC_VECTOR (15 downto 0));
end accumulation;

architecture Behavioral of accumulation is
    signal accumulator, sum : signed(15 downto 0);
    signal w16b : signed (15 downto 0);    
begin
    w16b <= to_signed(0, 16) + signed(weight);
    
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                accumulator <= "0000000000000000";
            else
                accumulator <= sum;
            end if;
        end if;
    end process;
    
    with pixel select
        sum <= w16b + accumulator when '1',
                  accumulator     when others ;
    accumulated <= STD_LOGIC_VECTOR(accumulator);

end Behavioral;
