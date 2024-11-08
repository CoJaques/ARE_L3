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
-- Author               : 
-- Date                 : 04.08.2022
--
-- Context              : Avalon user interface
--
------------------------------------------------------------------------------------------
-- Description : 
--   
------------------------------------------------------------------------------------------
-- Dependencies : 
--   
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver    Date        Engineer    Comments
-- 0.0    See header              Initial version

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

  --| Components declaration |--------------------------------------------------------------
  
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

  --| Signals declarations   |--------------------------------------------------------------   
    signal buttons_reg_s        : std_logic_vector(boutton_i'range);
    signal switches_reg_s       : std_logic_vector(switch_i'range);
    signal led_reg_s            : std_logic_vector(led_o'range);

    signal lp36_sel_s           : std_logic_vector(lp36_sel_o'range);
    signal lp36_data_s          : std_logic_vector(lp36_data_o'range);

    signal readdatavalid_next_s : std_logic;
    signal readdatavalid_reg_s  : std_logic;
    signal readdata_next_s      : std_logic_vector(avl_readdata_o'range);
    signal readdata_reg_s       : std_logic_vector(avl_readdata_o'range);

begin
    buttons_reg_s  <= boutton_i;
    switches_reg_s <= switch_i;

    -- Read decoder process
    read_decoder_p : process(all)
    begin
        --| Value by default
        readdatavalid_next_s <= '0';       
        readdata_next_s      <= (others => '0');

        if avl_read_i  = '1' then
            readdatavalid_next_s <= '1';
            case avl_address_i is
                when ID_ADDR        => readdata_next_s <= ID;
                when BUTTONS_ADDR   => readdata_next_s(boutton_i'range)   <= buttons_reg_s;
                when SWITCHES_ADDR  => readdata_next_s(switch_i'range)    <= switches_reg_s;
                when LED_ADDR       => readdata_next_s(led_o'range)       <= led_reg_s;
                when LP36_SEL_ADDR  => readdata_next_s(lp36_sel_o'range)  <= lp36_sel_s;
                when LP36_DATA_ADDR => readdata_next_s(lp36_data_o'range) <= lp36_data_s;
                when others         => null;
            end case;
        end if;
    end process;

    -- Read register process
    read_register_p : process(avl_reset_i, avl_clk_i)
    begin
        if avl_reset_i = '1' then
            readdatavalid_reg_s <= '0';
            readdata_reg_s      <= (others => '0');
        elsif rising_edge(avl_clk_i) then
            readdatavalid_reg_s <= readdatavalid_next_s;
            readdata_reg_s      <= readdata_next_s;
        end if;
    end process;

    -- Write channel with register
    write_register_p : process(avl_reset_i, avl_clk_i)
    begin
        --| Value by default
        led_reg_s   <= led_reg_s;
        lp36_sel_s  <= lp36_sel_s;
        lp36_data_s <= lp36_data_s;

        if avl_reset_i='1' then
            led_reg_s   <= (others => '0');
            lp36_sel_s  <= (others => '0');
            lp36_data_s <= (others => '0');
        elsif rising_edge(avl_clk_i) then
            if avl_write_i ='1' then
                case avl_address_i is
                    when LED_ADDR       => led_reg_s   <= avl_writedata_i(led_o'range);
                    when LP36_SEL_ADDR  => lp36_sel_s  <= avl_writedata_i(lp36_sel_o'range);
                    when LP36_DATA_ADDR => lp36_data_s <= avl_writedata_i;
                    when others   => null;
                end case;
            end if;
        end if;
    end process;

    -- Output signals
    avl_readdatavalid_o <= readdatavalid_reg_s;
    avl_readdata_o      <= readdata_reg_s;
    led_o               <= led_reg_s;
    lp36_sel_o          <= lp36_sel_s;
    lp36_data_o         <= lp36_data_s;
end rtl;
