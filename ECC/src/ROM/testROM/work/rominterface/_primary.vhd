library verilog;
use verilog.vl_types.all;
entity rominterface is
    generic(
        IDLE            : integer := 0;
        Addr            : integer := 1;
        \Cen\           : integer := 2;
        Finish          : integer := 3
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        i_rd_rom        : in     vl_logic;
        i_wr_rom        : in     vl_logic;
        i_addr_rom      : in     vl_logic_vector(6 downto 0);
        i_wordcnt_rom   : in     vl_logic_vector(3 downto 0);
        i_data_rom      : in     vl_logic_vector(15 downto 0);
        o_data_rom_16bits: out    vl_logic_vector(15 downto 0);
        o_fifo_full_rom : out    vl_logic;
        o_done_rom      : out    vl_logic;
        Q               : in     vl_logic_vector(15 downto 0);
        \CEN\           : out    vl_logic;
        A               : out    vl_logic_vector(6 downto 0)
    );
end rominterface;
