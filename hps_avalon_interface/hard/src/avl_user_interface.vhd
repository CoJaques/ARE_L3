------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : avl_user_interface.vhd
-- Author               : Theodros Mulugeta & Colin JAques 
-- Date                 : 04.08.2022
--
-- Context              : Avalon user interface
--
------------------------------------------------------------------------------------------
-- Description : 
-- Simple interface for LP36
------------------------------------------------------------------------------------------
-- Dependencies : 
--   
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver    Date        Engineer    Comments
-- 0.0    See header              Initial version
-- 1.0    09.11.24    CJ & TM     Initial implementation
------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
entity avl_user_interface is
  port(
    -- Avalon bus
    avl_clk_i           : in  std_logic;
    avl_reset_i         : in  std_logic;
    avl_address_i       : in  std_logic_vector(13 downto 0);
    avl_byteenable_i    : in  std_logic_vector(3 downto 0);
    avl_write_i         : in  std_logic;
    avl_writedata_i     : in  std_logic_vector(31 downto 0);
    avl_read_i          : in  std_logic;
    avl_readdatavalid_o : out std_logic;
    avl_readdata_o      : out std_logic_vector(31 downto 0);
    avl_waitrequest_o   : out std_logic;
    -- User interface
    boutton_i           : in  std_logic_vector(3 downto 0);
    switch_i            : in  std_logic_vector(9 downto 0);
    led_o               : out std_logic_vector(9 downto 0);
    lp36_we_o           : out std_logic;
    lp36_sel_o          : out std_logic_vector(3 downto 0);
    lp36_data_o         : out std_logic_vector(31 downto 0);
    lp36_status_i       : in  std_logic_vector(1 downto 0)
  );
end avl_user_interface;

architecture rtl of avl_user_interface is
  
  --| Constants declarations |--------------------------------------------------------------
    constant ID              : std_logic_vector(avl_readdata_o'range) := x"1234CAFE";
    constant ID_ADDR         : std_logic_vector(avl_address_i'range)  := "00" & x"000";
    constant BUTTONS_ADDR    : std_logic_vector(avl_address_i'range)  := "00" & x"001";
    constant SWITCHES_ADDR   : std_logic_vector(avl_address_i'range)  := "00" & x"003";
    constant LP36_STAT       : std_logic_vector(avl_address_i'range)  := "00" & x"004";
    constant LP36_RDY        : std_logic_vector(avl_address_i'range)  := "00" & x"005";
    constant LED_ADDR        : std_logic_vector(avl_address_i'range)  := "00" & x"020";
    constant LP36_SEL_ADDR   : std_logic_vector(avl_address_i'range)  := "00" & x"021";
    constant LP36_DATA_ADDR  : std_logic_vector(avl_address_i'range)  := "00" & x"022";
    constant CYCLE_WRITE     : unsigned(5 downto 0)                   := TO_UNSIGNED(50, 6);

  --| Signals declarations   |--------------------------------------------------------------   
    signal buttons_reg_s         : std_logic_vector(boutton_i'range);
    signal switches_reg_s       : std_logic_vector(switch_i'range);
    signal led_reg_s            : std_logic_vector(led_o'range);

    signal lp36_sel_reg_s       : std_logic_vector(lp36_sel_o'range);
    signal lp36_data_reg_s      : std_logic_vector(lp36_data_o'range);
    signal lp36_status_reg_s    : std_logic_vector(lp36_status_i'range);

    signal readdatavalid_next_s : std_logic;
    signal readdatavalid_reg_s  : std_logic;
    signal readdata_next_s      : std_logic_vector(avl_readdata_o'range);
    signal readdata_reg_s       : std_logic_vector(avl_readdata_o'range);

    type lp36_state_t is (
        IDLE,
        WE_DATA,
        WE_SEL,
        WE_RST,
        WE_BOTH
    );

    signal lp36_state_pres_s, lp36_state_fut_s : lp36_state_t;
    signal lp36_we_sel_s, lp36_we_data_s       : std_logic;
    signal timer_reset_s  : std_logic;
    signal counter_done_s : std_logic;
    signal counter_pres_s, counter_fut_s : unsigned(5 downto 0);
    signal cs_wr_lp36_sel_s  : std_logic;
    signal cs_wr_lp36_data_s : std_logic;
    signal lp36_rdy_s        : STD_LOGIC;

begin
    -- -----------------------------------------
    -- Read
    -- -----------------------------------------

    -- Read synchronisation process
    sync_input_reg: process (avl_clk_i, avl_reset_i)
    begin
        if avl_reset_i = '1' then
            buttons_reg_s      <= (others => '0');
            switches_reg_s     <= (others => '0');
            lp36_status_reg_s  <= (others => '0');
        elsif rising_edge(avl_clk_i) then
            buttons_reg_s     <= boutton_i;
            switches_reg_s    <= switch_i;
            lp36_status_reg_s <= lp36_status_i;
        end if;
    end process;

    -- Read multiplexer process
    read_decoder_p : process(all)
    begin
        --| Value by default
        readdata_next_s      <= (others => '0');

        case avl_address_i is 
            when ID_ADDR        => readdata_next_s <= ID;
            when BUTTONS_ADDR   => readdata_next_s(boutton_i'range)         <= buttons_reg_s; 
            when SWITCHES_ADDR  => readdata_next_s(switch_i'range)          <= switches_reg_s;
            when LP36_STAT      => readdata_next_s(lp36_status_reg_s'range) <= lp36_status_reg_s;
            when LP36_RDY       => readdata_next_s(0)                       <= lp36_rdy_s;
            when LED_ADDR       => readdata_next_s(led_o'range)             <= led_reg_s;
            when LP36_SEL_ADDR  => readdata_next_s(lp36_sel_o'range)        <= lp36_sel_reg_s;
            when LP36_DATA_ADDR => readdata_next_s(lp36_data_o'range)       <= lp36_data_reg_s;
            when others         => null;
        end case;
    end process;

    -- Read register process
    read_register_p : process(avl_reset_i, avl_clk_i)
    begin
        if avl_reset_i = '1' then
            readdatavalid_reg_s <= '0';
            readdata_reg_s      <= (others => '0');
        elsif rising_edge(avl_clk_i) then
            readdatavalid_reg_s <= avl_read_i;
            if avl_read_i = '1' then
                readdata_reg_s  <= readdata_next_s;
            end if;
        end if;
    end process;

    -- -----------------------------------------
    -- Write
    -- -----------------------------------------

    -- Write channel with register
    write_register_p : process(avl_reset_i, avl_clk_i)
    begin
        if avl_reset_i='1' then
            led_reg_s         <= (others => '0');
            lp36_sel_reg_s    <= (others => '0');
            lp36_data_reg_s   <= (others => '0');
            cs_wr_lp36_sel_s  <= '0';
            cs_wr_lp36_data_s <= '0';
        elsif rising_edge(avl_clk_i) then
            cs_wr_lp36_sel_s  <= '0';
            cs_wr_lp36_data_s <= '0';

            if avl_write_i ='1' then
                case avl_address_i is
                    when LED_ADDR       => led_reg_s <= avl_writedata_i(led_o'range);
                    when LP36_SEL_ADDR  => 
                        if lp36_we_sel_s = '0' then
                            lp36_sel_reg_s   <= avl_writedata_i(lp36_sel_o'range);
                            cs_wr_lp36_sel_s <= '1';
                        end if;
                    when LP36_DATA_ADDR => 
                        if lp36_we_sel_s = '0' then
                            lp36_data_reg_s   <= avl_writedata_i;
                            cs_wr_lp36_data_s <= '1';
                        end if;
                    when others         => null;
                end case;
            end if;
        end if;
    end process;

    -- -----------------------------------------
    -- LP36_management counter
    -- -----------------------------------------
    counter: process (avl_clk_i, avl_reset_i)
    begin
        if avl_reset_i = '1' then
            counter_pres_s <= (others => '0');
        elsif rising_edge(avl_clk_i) then
            counter_pres_s <= counter_fut_s;
        end if;
    end process counter;

    counter_fut_s <= TO_UNSIGNED(0, counter_fut_s'length) when timer_reset_s = '1' else
                     counter_pres_s + 1;

    counter_done_s <= '1' when counter_pres_s >= CYCLE_WRITE else '0';

    -- -----------------------------------------
    -- LP36_management MSS
    -- -----------------------------------------

    mss_state_reg : process (avl_clk_i, avl_reset_i) is
    begin
        if avl_reset_i = '1' then
            lp36_state_pres_s <= IDLE;
        elsif rising_edge(avl_clk_i) then
            lp36_state_pres_s <= lp36_state_fut_s;
        end if;
    end process mss_state_reg;

    mss_fut_dec : process (lp36_state_pres_s, lp36_we_data_s, lp36_we_sel_s, counter_done_s) is
    begin
        lp36_we_sel_s  <= '0';
        lp36_we_data_s <= '0';
        timer_reset_s  <= '0';

        case lp36_state_pres_s is
            when IDLE =>
                if cs_wr_lp36_data_s   = '1' then
                    lp36_state_fut_s <= WE_DATA;
                elsif cs_wr_lp36_sel_s = '1' then
                    lp36_state_fut_s <= WE_SEL;
                end if;

                timer_reset_s <= '1';
            when WE_DATA =>
                if cs_wr_lp36_sel_s then
                    lp36_state_fut_s <= WE_RST;
                elsif counter_done_s then
                    lp36_state_fut_s <= IDLE;
                end if;

                lp36_we_data_s <= '1';
            when WE_SEL =>
                if cs_wr_lp36_data_s then
                    lp36_state_fut_s <= WE_RST;
                elsif counter_done_s then
                    lp36_state_fut_s <= IDLE;
                end if;

                lp36_we_sel_s <= '1';
            when WE_RST =>
                lp36_state_fut_s <= WE_BOTH;
                lp36_we_sel_s    <= '1';
                lp36_we_data_s   <= '1';
                timer_reset_s    <= '1';
            when WE_BOTH =>
                if counter_done_s then
                    lp36_state_fut_s <= IDLE;
                end if;

                lp36_we_sel_s  <= '1';
                lp36_we_data_s <= '1';
        end case;
    end process mss_fut_dec;

    -- -----------------------------------------
    -- Internal signals
    -- -----------------------------------------
    lp36_rdy_s     <= not(lp36_we_sel_s or lp36_we_data_s);

    -- -----------------------------------------
    -- Output signals
    -- -----------------------------------------
    avl_readdatavalid_o <= readdatavalid_reg_s;
    avl_readdata_o      <= readdata_reg_s;
    led_o               <= led_reg_s;
    lp36_sel_o          <= lp36_sel_reg_s;
    lp36_data_o         <= lp36_data_reg_s;
    lp36_we_o           <= lp36_we_sel_s or lp36_we_data_s;
end rtl;
