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
           done : out STD_LOGIC);
end neuron_ctrl;

architecture Behavioral of neuron_ctrl is
 
    type state_type is (IDLE, READ, COMPUTE);
    --signal read_op : STD_LOGIC_VECTOR(1 downto 0);
    --signal compute_op, busy_reg : STD_LOGIC;
    
    --state machine registers
    signal state_reg, state_next : state_type;
    
    --MAC signals
    signal image_px, mac_valid, mac_opcode : STD_LOGIC;
    signal mac_weight : STD_LOGIC_VECTOR(7 downto 0);
    signal mac_bias : STD_LOGIC_VECTOR(31 downto 0);
    signal mac_accumulated : STD_LOGIC_VECTOR(15 downto 0);
    
    
    
   
    --internal control signals 
    signal ubias_addr : unsigned(5 downto 0);
    signal uweight_addr : STD_LOGIC_VECTOR(15 downto 0);
    signal rom_data_valid : STD_LOGIC;
    
        --internal registers
    signal weight_count : unsigned(9 downto 0);
    signal read_valid : STD_LOGIC_VECTOR(1 downto 0);
    
begin
    
    MAC1 : entity work.accumulation(Behavioral)
        port map(
            clk => clk,
            reset => reset,
            pixel => image_px,
            valid => rom_data_valid,
            opcode => mac_opcode,
            weight =>  mac_weight,
            bias => mac_bias,
            accumulated => mac_accumulated
        );
        
    WROM1 : entity work.w1_blk_rom
        port map(
            clka => clk,
            addra => uweight_addr,
            douta => mac_weight
        );
        
        process(clk)
        begin
            if rising_edge(clk) then
                if reset = '1' then
                    state_reg <= IDLE;
                    ubias_addr <= (others => '0');
                    uweight_addr <= (others => '0');
                    weight_count <= (others => '0');
                    read_valid <= "00";
                else 
                    state_reg <= state_next;
                    case state_reg is
                        when READ =>
                            if read_valid = "00" then
                                read_valid(0) <= '1';
                            elsif read_valid = "01" then
                                read_valid(0) <= '0';
                                read_valid(1) <= read_valid(0);
                            else
                                read_valid <= "00";
                            end if;
                        when COMPUTE =>
                            weight_count <= weight_count + 1;
                            ubias_addr <= ubias_addr + 1;
                            uweight_addr <= STD_LOGIC_VECTOR(unsigned(uweight_addr) + 1);
                        when others =>
                            weight_count <= weight_count;
                            ubias_addr <= ubias_addr;
                            uweight_addr <= uweight_addr;
                        end case;
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
                if weight_count = 783 then
                    state_next <= IDLE;
                else
                    state_next <= READ;
                end if;
            when others =>
                state_next <= IDLE;
        end case; 
    end process;    
    
    --rom_data_valid <= '1' when state_reg = READ else '0';
    rom_data_valid <= '1' when read_valid = "10" else '0';
    --mac_valid <= '1' when read_valid = "10" else '0';
    
    
    --***working to get mac_opcode to be correct for bias or weight loading
    -- additionally need to generate pixel ROM and figure out specifics
    mac_opcode <= '0' when start = '0' else '1';
    
    
end Behavioral;