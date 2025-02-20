
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library src_lib;

library common;
    use common.type_declaration_pkg.all;
--

library vunit_lib;
    context vunit_lib.vunit_context;
    use vunit_lib.array_pkg.all;
    use vunit_lib.integer_array_pkg.all;

entity top_tb is
    generic (
        g_TEST_NAME : string;
        g_TB_PATH   : string;
        RUNNER_CFG  : string
    );
end entity top_tb;

architecture bench of top_tb is
    -- Clock period
    constant cnt_CLK_PERIOD : time := 5 ns;
    -- Generics
    constant cnt_DATA_WIDTH : positive := 8;
    -- Ports
    signal clk            : std_logic := '0';
    signal data_valid_in  : std_logic := '0';
    signal data_in        : t_data(data_0(cnt_DATA_WIDTH - 1 downto 0), data_1(cnt_DATA_WIDTH - 1 downto 0));
    signal data_valid_out : std_logic;
    signal data_out       : std_logic_vector(cnt_DATA_WIDTH downto 0);
    signal operation_in   : std_logic;



    signal finish_test : boolean := false;
begin

    top_inst : entity src_lib.top
        generic map (
            g_data_width => cnt_DATA_WIDTH
        )
        port map (
            clk            => clk,
            data_valid_in  => data_valid_in,
            data_in        => data_in,
            data_valid_out => data_valid_out,
            data_out       => data_out,
            operation_in   => operation_in
        );

    main : process is
        variable data_input_0 : integer_array_t;
        variable data_input_1 : integer_array_t;

    begin
        test_runner_setup(runner, RUNNER_CFG);
        while test_suite loop
            data_input_0 := load_csv(g_TB_PATH & "/" & g_TEST_NAME & "_input_0.csv");
            data_input_1 := load_csv(g_TB_PATH & "/" & g_TEST_NAME & "_input_1.csv");

            if run("check_adder") then
                wait for 10 * cnt_CLK_PERIOD;
                wait until (rising_edge(clk));

                operation_in <= '0';
                for i in 0 to data_input_0.length - 1 loop
                    data_valid_in  <= '1';
                    data_in.data_0 <= std_logic_vector(to_signed(get(data_input_0, i), cnt_DATA_WIDTH));
                    data_in.data_1 <= std_logic_vector(to_signed(get(data_input_1, i), cnt_DATA_WIDTH));
                    wait until (rising_edge(clk));
                end loop;
                data_valid_in <= '0';

                wait for 10 * cnt_CLK_PERIOD;
                finish_test <= true;
                wait for 10 * cnt_CLK_PERIOD;

                test_runner_cleanup(runner);
            elsif run("check_sub") then
                wait for 10 * cnt_CLK_PERIOD;

                wait for 10 * cnt_CLK_PERIOD;
                test_runner_cleanup(runner);
            end if;
        end loop;
    end process main;

    get_output_proc : process is
        variable data_output_array : integer_array_t := new_1d(length => 0, bit_width => cnt_DATA_WIDTH + 1, is_signed => true);

    begin
        if (finish_test) then
            info("Test finished");
            save_csv(data_output_array, g_TB_PATH & "/" & g_TEST_NAME & "_output.csv");
            wait;
        else
            if (data_valid_out = '1') then
                append(data_output_array, to_integer(signed(data_out)));
            end if;
        end if;
        wait until rising_edge(clk);
    end process get_output_proc;

    clk <= not clk after cnt_CLK_PERIOD / 2;

end architecture bench;
