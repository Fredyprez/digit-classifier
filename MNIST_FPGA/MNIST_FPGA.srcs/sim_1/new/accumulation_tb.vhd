----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2026 03:05:50 PM
-- Design Name: 
-- Module Name: accumulated_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity accumulation_tb is
end accumulation_tb;

architecture Testbench of accumulation_tb is
    constant T : time := 10ns;
    signal weight_t : STD_LOGIC_VECTOR (7 downto 0);
    signal clk_t : STD_LOGIC;
    signal reset_t : STD_LOGIC;
    signal px_t : STD_LOGIC;
    signal accumulated_t : STD_LOGIC_VECTOR (15 downto 0);
begin
    UUT : entity work.accumulation(Behavioral)
        port map(
            clk => clk_t,
            reset => reset_t,
            weight => weight_t,
            pixel => px_t,
            accumulated => accumulated_t
        );
        
    process
    begin
        clk_t <= '0';
        wait for T/2;
        clk_t <= '1';
        wait for T/2;
    end process;
    
    --reset_t <= '1', '0' after T*2;
    
    process
    begin
        reset_t <= '1';
        wait until rising_edge(clk_t);
        wait until rising_edge(clk_t);
        reset_t <= '0';
        weight_t <= x"10";
        px_t <= '0';
        wait until falling_edge(clk_t);
        wait until falling_edge(clk_t);
        px_t <= '1';
        weight_t <= x"FF";
        for i in 1 to 10 loop
            wait until falling_edge(clk_t);
        end loop;
        wait until falling_edge(clk_t);
        reset_t <= '1';
        wait until rising_edge(clk_t);
        reset_t <= '0';
        wait until rising_edge(clk_t);
        px_t <= '0';
        wait until falling_edge(clk_t);
        weight_t <= x"78";
        wait until falling_edge(clk_t);
        weight_t <= x"64";
        wait until falling_edge(clk_t);
        px_t <= '1';
        wait until falling_edge(clk_t);
        assert false
            report "Simulation Completed"
            severity failure;
    end process;
end Testbench;
