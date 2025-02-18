library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity memory is
    generic (
        g_DATA_WIDTH : positive := 8;
        g_ADDR_WIDTH : positive := 4;
        g_RAM_STYLE  : string   := "BLOCK"
    );
    port (
        clk : in    std_logic;

        write_enable_in  : in    std_logic;
        write_address_in : in    std_logic_vector(g_ADDR_WIDTH - 1 downto 0);
        data_in          : in    std_logic_vector(g_DATA_WIDTH - 1 downto 0);

        read_enable_in   : in    std_logic;
        read_address_in  : in    std_logic_vector(g_ADDR_WIDTH - 1 downto 0);
        data_out         : out   std_logic_vector(g_DATA_WIDTH - 1 downto 0);
        write_enable_out : out   std_logic
    );
end entity memory;

architecture bram_mem of memory is
    type   t_memory_array is array (0 to 2 ** g_ADDR_WIDTH - 1) of std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal mem : t_memory_array := (others => (others => '0'));

    attribute ram_style : string;
    attribute ram_style of mem : signal is g_RAM_STYLE;
begin

    memory_write : process (clk) is
    begin
        if rising_edge(clk) then
            if (write_enable_in = '1') then
                mem(to_integer(unsigned(write_address_in))) <= data_in;
            end if;
        end if;
    end process memory_write;

    memory_read : process (clk) is
    begin
        if rising_edge(clk) then
            if (read_enable_in = '1') then
                data_out         <= mem(to_integer(unsigned(read_address_in)));
                write_enable_out <= '1';
            else
                write_enable_out <= '0';
            end if;
        end if;
    end process memory_read;

end architecture bram_mem;

architecture rtl_mem of memory is
    type   t_memory_array is array (0 to 2 ** g_ADDR_WIDTH - 1) of std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal mem : t_memory_array := (others => (others => '0'));
begin

    memory_write : process (clk) is
    begin
        if rising_edge(clk) then
            if (write_enable_in = '1') then
                mem(to_integer(unsigned(write_address_in))) <= data_in;
                -- mem(to_integer(unsigned(write_address_in))) <= (others => '0');
            end if;
        end if;
    end process memory_write;

    memory_read : process (clk) is
    begin
        if rising_edge(clk) then
            if (read_enable_in = '1') then
                data_out         <= mem(to_integer(unsigned(read_address_in)));
                write_enable_out <= '1';
            else
                write_enable_out <= '0';
            end if;
        end if;
    end process memory_read;

end architecture rtl_mem;
