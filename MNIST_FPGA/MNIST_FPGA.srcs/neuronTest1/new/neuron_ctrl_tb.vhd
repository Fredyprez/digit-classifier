
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity neuron_ctrl_tb is
end neuron_ctrl_tb;

architecture Testbench of neuron_ctrl_tb is
    constant T : time := 10ns;

    signal clk_t, reset_t, start_t, busy_t, done_t : STD_LOGIC;

    signal bias_t : STD_LOGIC_VECTOR(31 downto 0) := x"FFFFFFFA";
    signal weight_addr_t : STD_LOGIC_VECTOR(15 downto 0) := x"0000";

begin

    neuron_controller : entity work.neuron_ctrl(Behavioral)
        port map(
            clk => clk_t,
            reset => reset_t,
            mac_bias => bias_t,
            weight_base_addr => weight_addr_t,
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

        wait until done_t = '1';
        wait until rising_edge(clk_t);
        wait for 1 ns;

        assert false
            report "Simulation Completed"
            severity failure;
    end process;

end Testbench;
