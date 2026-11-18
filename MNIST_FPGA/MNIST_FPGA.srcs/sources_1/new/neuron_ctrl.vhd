----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/31/2026 10:31:03 PM
-- Design Name: 
-- Module Name: neuron_ctrl - Behavioral
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



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity neuron_ctrl is
    Port ( start : in STD_LOGIC;
           clk, reset : in STD_LOGIC;
           busy : out STD_LOGIC;
           done : out STD_LOGIC
           );
end neuron_ctrl;

architecture Behavioral of neuron_ctrl is
 
    type state_type is (IDLE, READ, COMPUTE);
    signal read_op : STD_LOGIC_VECTOR(1 downto 0);
    signal compute_op, busy_reg : STD_LOGIC;
    signal state_reg, state_next : state_type;
    signal image_px, mac_valid, mac_opcode : STD_LOGIC;
    signal mac_weight : STD_LOGIC_VECTOR(7 downto 0);
    signal mac_bias : STD_LOGIC_VECTOR(31 downto 0);
    signal mac_accumulated : STD_LOGIC_VECTOR(15 downto 0);
    signal uweight_addr : unsigned(15 downto 0);
    signal ubias_addr, weight_count : unsigned(5 downto 0);
    signal rom_data_valid : STD_LOGIC;
    
begin
    
    MAC1 : entity work.accumulation(Behavioral)
        port map(
            clk => clk,
            reset => reset,
            pixel => image_px,
            valid => mac_valid,
            opcode => mac_opcode,
            weight =>  mac_weight,
            bias => mac_bias,
            accumulated => mac_accumulated
        );
        
        process(clk)
        begin
            if rising_edge(clk) then
                if reset = '1' then
                    state_reg <= IDLE;
                    ubias_addr <= (others => '0');
                    uweight_addr <= (others => '0');
                else
                    state_reg <= state_next;
                 end if;
            end if;
        end process;
    
    --next state logic
    process(state_reg, start, rom_data_valid, weight_count)
    begin
        state_next <= state_reg;
        case state_reg is
            when IDLE =>
                if start = '1' then
                    state_next <= READ;
                else
                    state_next <= IDLE;
                end if;
            when READ =>
                if rom_data_valid = '1' then
                    state_next <= COMPUTE;
                else
                    state_next <= READ;
                end if;
            when COMPUTE =>
                if weight_count < 784 then
                    state_next <= READ;
                else
                    state_next <= IDLE;
                end if;
            when others =>
                state_next <= IDLE;
        end case; 
    end process;    
    
end Behavioral;