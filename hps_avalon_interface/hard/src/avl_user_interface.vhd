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
    -- ID
    constant ID               : std_logic_vector(avl_readdata_o'range):= x"1234CAFE";

    --| Address
    constant ID_ADDR          : integer := 16#0#;  -- Adresse 0x00
    constant BUTTONS_ADDR     : integer := 16#1#;  -- Adresse 0x01
    constant SWITCHES_ADDR    : integer := 16#2#;  -- Adresse 0x02
    constant LP36_STAT        : integer := 16#3#;  -- Adresse 0x03
    constant LP36_RDY         : integer := 16#4#;  -- Adresse 0x04
    constant LED_ADDR         : integer := 16#80#; -- Adresse 0x80
    constant LP36_SEL_ADDR    : integer := 16#81#; -- Adresse 0x81
    constant LP36_DATA_ADDR   : integer := 16#82#; -- Adresse 0x82

  --| Signals declarations   |--------------------------------------------------------------   

  signal buttons_s            : std_logic_vector(3 downto 0);
  signal switches_s           : std_logic_vector(9 downto 0);
  signal led_reg_s            : std_logic_vector(9 downto 0);
  signal readdatavalid_next_s : std_logic;
  signal readdatavalid_reg_s  : std_logic;
  signal readdata_next_s      : std_logic_vector(31 downto 0);
  signal readdata_reg_s       : std_logic_vector(31 downto 0);

begin
  buttons_s  <= boutton_i;
  switches_s <= switch_i;
  led_reg_s  <= "1101010011";

    -- Read decoder process
    read_decoder_p : process(all)
    begin
        --| Value by default
        readdatavalid_next_s <= '0';       
        readdata_next_s      <= (others => '0');

        if avl_read_i  = '1' then
            readdatavalid_next_s <= '1';
            case to_integer(unsigned(avl_address_i)) is
                when ID_ADDR =>
                    readdata_next_s <= ID;
                when BUTTONS_ADDR =>
                    readdata_next_s(3 downto 0) <= buttons_s;
                when SWITCHES_ADDR =>
                    readdata_next_s(9 downto 0) <= switch_i;
                when LED_ADDR =>
                    readdata_next_s(9 downto 0) <= led_reg_s;
                when others =>
                    null;
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

    -- Output signals from read
    avl_readdatavalid_o <= readdatavalid_reg_s;
    avl_readdata_o      <= readdata_reg_s;




  

    -- | Write
     -- Input signals

    -- Write channel with register
    write_register_p : process(avl_reset_i, avl_clk_i)
    begin
        if avl_reset_i='1' then
            led_reg_s <= (others => '0');
        elsif rising_edge(avl_clk_i) then
            if avl_write_i ='1' then
                case (to_integer(unsigned(avl_address_i))) is
                    when LED_ADDR =>
                        led_reg_s <= avl_writedata_i(9 downto 0);
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    -- Output signals from write
    led_o       <= led_reg_s;

end rtl;
