
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity accumulation is
    generic(N : integer := 16);
    Port (
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        valid       : in STD_LOGIC;
        opcode      : in STD_LOGIC;
        pixel       : in STD_LOGIC_VECTOR(0 downto 0);
        weight      : in STD_LOGIC_VECTOR(7 downto 0);
        bias        : in STD_LOGIC_VECTOR(31 downto 0);
        accumulated : out STD_LOGIC_VECTOR(N - 1 downto 0)
    );
end accumulation;

architecture Behavioral of accumulation is
    signal accumulator, next_value, contribution : signed(N - 1 downto 0);
    signal w16b, bias16b : signed(N - 1 downto 0);
    signal ctrl : std_logic_vector(1 downto 0);
begin
    w16b <= to_signed(0, 16) + signed(weight);
    bias16b <= signed(bias(N - 1 downto 0));
    ctrl <= valid & opcode;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                accumulator <= (others => '0');
            else
                accumulator <= next_value;
            end if;
        end if;
    end process;

    with pixel(0) select
        contribution <= w16b when '1',
                        x"0000" when others;

    with ctrl select
        next_value <= contribution + accumulator when "10",
                      bias16b + accumulator when "01",
                      accumulator when others;

    accumulated <= STD_LOGIC_VECTOR(accumulator);

end Behavioral;
