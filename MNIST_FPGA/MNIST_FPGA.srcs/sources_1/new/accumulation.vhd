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
        generic(N : integer := 16);
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               pixel, valid, opcode : in STD_LOGIC;
               weight : in STD_LOGIC_VECTOR (7 downto 0);
               bias : in STD_LOGIC_VECTOR (31 downto 0);
               accumulated : out STD_LOGIC_VECTOR (N - 1 downto 0));
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
        
        with pixel select
            contribution <= w16b when '1',
                            x"0000" when others;
        
        with ctrl select
            next_value <= contribution + accumulator when "10",
                           bias16b            when "11" | "01",
                           accumulator        when others;
                           
        accumulated <= STD_LOGIC_VECTOR(accumulator);
    
    end Behavioral;
