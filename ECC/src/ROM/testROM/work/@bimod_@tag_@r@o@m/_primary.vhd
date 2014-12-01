library verilog;
use verilog.vl_types.all;
entity Bimod_Tag_ROM is
    generic(
        BITS            : integer := 16;
        WORD_DEPTH      : integer := 128;
        ADDR_WIDTH      : integer := 7;
        WEN_WIDTH       : integer := 1;
        WP_SIZE         : integer := 16;
        RCOLS           : integer := 0;
        MUX             : integer := 16;
        COL_ADDR_WIDTH  : integer := 4;
        RROWS           : integer := 0;
        UPM_WIDTH       : integer := 3;
        RCA_WIDTH       : integer := 1;
        RED_COLUMNS     : integer := 2
    );
    port(
        Q               : out    vl_logic_vector(15 downto 0);
        CLK             : in     vl_logic;
        CEN             : in     vl_logic;
        A               : in     vl_logic_vector(6 downto 0)
    );
end Bimod_Tag_ROM;
