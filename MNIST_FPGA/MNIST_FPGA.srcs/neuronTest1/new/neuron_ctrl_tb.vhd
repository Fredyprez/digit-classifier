----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/23/2026 03:07:59 PM
-- Design Name: 
-- Module Name: neuron_ctrl_tb - Testbench
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

entity neuron_ctrl_tb is
--  Port ( );
end neuron_ctrl_tb;

architecture Testbench of neuron_ctrl_tb is
    constant T : time := 10ns;
    
    signal clk_t, reset_t, start_t, busy_t, done_t : STD_LOGIC;
begin
    neuron_controller : entity work.neuron_ctrl(Behavioral)
        port map(
            clk => clk_t,
            reset => reset_t,
            start => start_t,
            busy => busy_t,
            done => done_t 
        );
        
        process
        begin
            clk_t <= '0';
            wait for T/2;
            clk_t <= '1';
            wait for T/2;
        end process;
        
        reset_t <= '1', '0' after T;
        
        process
        begin
        start_t <= '0';

        wait for 15ns;
        wait until falling_edge(clk_t);

        start_t <= '1';
        wait until falling_edge(clk_t);

        start_t <= '0';
        wait for 100100ns;
        
        assert false
            report "Simulation Completed"
            severity failure;
        end process;
        
        

end Testbench;
