----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/02/2026 04:51:50 PM
-- Design Name: 
-- Module Name: weight_rom - Behavioral
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
library STD;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity weight_rom is
    Port ( clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (15 downto 0);
           opcode : in STD_LOGIC;
           dout : out STD_LOGIC_VECTOR (7 downto 0));
end weight_rom;

architecture Behavioral of weight_rom is
    type w1ROM is array(0 to 50175) of STD_LOGIC_VECTOR(7 downto 0);
    type w2ROM is array(639 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
    impure function Initw1RomFromFile (w1RomFileName : in string) return w1ROM is
        FILE w1RomFile : text open read_mode is w1RomFileName;
        variable w1RomFileLine : line;
        variable w1ROM: w1ROM;
    begin
        for I in w1ROM'range loop
            readline(w1RomFile, w1RomFileLine);
            hread(w1RomFileLine, w1ROM(I));
        end loop;
        return w1ROM;
    end function;
    impure function Initw2RomFromFile (w2RomFileName : in string) return w2ROM is
        FILE w2RomFile : text open read_mode is w2RomFileName;
        variable w2RomFileLine : line;
        variable w2ROM : w2ROM;
    begin
        for I in w2ROM'range loop
            readline(w2RomFile, w2RomFileLine);
            hread(w2RomFileLine, w2ROM(I));
        end loop;
        return w2ROM;
    end function;
    signal weights1 : w1ROM := Initw1RomFromFile("w1.mem");
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
                dout <= weights1(TO_INTEGER(unsigned(addr)));
            end if;
    end process;

end Behavioral;
