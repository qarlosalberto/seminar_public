library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library common;
    use common.type_declaration_pkg.all;

library dsp;

entity top is
    generic (
        g_DATA_WIDTH : positive := 8
    );
    port (
        clk            : in    std_logic;
        data_valid_in  : in    std_logic;
        data_in        : in    t_data(data_0(g_DATA_WIDTH - 1 downto 0), data_1(g_DATA_WIDTH - 1 downto 0));
        data_valid_out : out   std_logic;
        data_out       : out   std_logic_vector(g_DATA_WIDTH downto 0);
        --! 0 for add, 1 for sub
        operation_in : in    std_logic
    );
end entity top;

architecture rtl of top is
    signal adder_data_out : std_logic_vector(g_DATA_WIDTH downto 0);
    signal sub_data_out   : std_logic_vector(g_DATA_WIDTH downto 0);
    signal r0_operation   : std_logic;
    signal r0_data_valid  : std_logic;
begin

    reg_0 : process (clk) is
    begin
        if rising_edge(clk) then
            r0_operation  <= operation_in;
            r0_data_valid <= data_valid_in;
        end if;
    end process reg_0;

    adder_inst : entity dsp.adder
        generic map (
            g_data_width => g_DATA_WIDTH
        )
        port map (
            clk      => clk,
            data_in  => data_in,
            data_out => adder_data_out
        );

    sub_inst : entity dsp.sub
        generic map (
            g_data_width => g_DATA_WIDTH
        )
        port map (
            clk      => clk,
            data_in  => data_in,
            data_out => sub_data_out
        );

    dsp_proc : process (clk) is
    begin
        if rising_edge(clk) then
            if (r0_operation = '0') then
                data_out <= adder_data_out;
            else
                data_out <= sub_data_out;
            end if;
            data_valid_out <= r0_data_valid;
        end if;
    end process dsp_proc;

end architecture rtl;
