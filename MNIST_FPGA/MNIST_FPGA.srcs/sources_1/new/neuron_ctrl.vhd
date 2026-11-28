
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity neuron_ctrl is
    Port (
        start            : in  STD_LOGIC;
        clk, reset       : in  STD_LOGIC;
        mac_bias             : in  STD_LOGIC_VECTOR(31 downto 0);
        weight_base_addr : in  STD_LOGIC_VECTOR(15 downto 0);
        busy             : out STD_LOGIC;
        done             : out STD_LOGIC
    );
end neuron_ctrl;

architecture Behavioral of neuron_ctrl is

    type state_type is (IDLE, READ, COMPUTE, LOAD_BIAS);
    signal state_reg, state_next : state_type;

    signal mac_opcode : STD_LOGIC;
    signal image_px : STD_LOGIC_VECTOR(0 downto 0);
    signal mac_weight : STD_LOGIC_VECTOR(7 downto 0);
    signal mac_accumulated : STD_LOGIC_VECTOR(15 downto 0);
    signal mac_reset : STD_LOGIC;

    signal uweight_addr : STD_LOGIC_VECTOR(15 downto 0);
    signal px_addr : STD_LOGIC_VECTOR(17 downto 0);

    signal rom_data_valid : STD_LOGIC;

    signal weight_count : unsigned(9 downto 0);
    signal read_valid : STD_LOGIC_VECTOR(1 downto 0);

begin

    MAC1 : entity work.accumulation(Behavioral)
        port map(
            clk => clk,
            reset => mac_reset,
            pixel => image_px,
            valid => rom_data_valid,
            opcode => mac_opcode,
            weight => mac_weight,
            bias => mac_bias,
            accumulated => mac_accumulated
        );

    WROM1 : entity work.w1_blk_rom
        port map(
            clka => clk,
            addra => uweight_addr,
            douta => mac_weight
        );

    PXROM : entity work.px_blk_rom
        port map(
            clka => clk,
            addra => px_addr,
            douta => image_px
        );

    mac_reset <= '1' when
        reset = '1' or (state_reg = IDLE and start = '1')
        else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state_reg <= IDLE;
                px_addr <= (others => '0');
                uweight_addr <= (others => '0');
                weight_count <= (others => '0');
                read_valid <= "00";
            else
                state_reg <= state_next;

                case state_reg is
                    when IDLE =>
                        if start = '1' then
                            px_addr <= (others => '0');
                            uweight_addr <= weight_base_addr;
                            weight_count <= (others => '0');
                            read_valid <= "00";
                        end if;

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
                        px_addr <= STD_LOGIC_VECTOR(unsigned(px_addr) + 1);
                        uweight_addr <= STD_LOGIC_VECTOR(unsigned(uweight_addr) + 1);
                        weight_count <= weight_count + 1;

                    when LOAD_BIAS =>
                        null;

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

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
                    state_next <= LOAD_BIAS;
                else
                    state_next <= READ;
                end if;

            when LOAD_BIAS =>
                state_next <= IDLE;

            when others =>
                state_next <= IDLE;
        end case;
    end process;

    rom_data_valid <= '1' when read_valid = "10" else '0';

    mac_opcode <= '1' when state_reg = LOAD_BIAS else '0';

    busy <= '0' when state_reg = IDLE else '1';
    done <= '1' when state_reg = LOAD_BIAS else '0';

end Behavioral;
