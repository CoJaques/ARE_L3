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
    
    --| Signals declarations   |--------------------------------------------------------------   
    signal read_data_internal  : std_logic_vector(31 downto 0);
    signal read_valid          : std_logic;
    signal user_id             : std_logic_vector(31 downto 0) := x"CAFEBABE"; -- Sample user ID
    signal buttons             : std_logic_vector(3 downto 0);
    signal switches            : std_logic_vector(9 downto 0);
    signal leds                : std_logic_vector(9 downto 0);
    signal parallel_we         : std_logic;
    signal parallel_sel        : std_logic_vector(3 downto 0);
    signal parallel_data       : std_logic_vector(31 downto 0);
    signal decoded_address     : std_logic_vector(13 downto 0);

begin

    -- Read access part
    process(avl_clk_i)
    begin
        if rising_edge(avl_clk_i) then
            if avl_read_i = '1' then
                case decoded_address is
                    when x"010000" =>  -- Interface user ID (32-bit)
                        read_data_internal <= user_id;
                    when x"010004" =>  -- Read DE1-SoC Buttons (4 Keys)
                        read_data_internal(3 downto 0) <= boutton_i;
                    when x"010008" =>  -- Read DE1-SoC Switches (10 Switches)
                        read_data_internal(9 downto 0) <= switch_i;
                    when x"01000C" to x"01001F" =>  -- Read DE1-SoC LEDs (10 LEDs)
                        read_data_internal(9 downto 0) <= led_o;
                    when x"010020" to x"01002F" =>  -- Read Max10 status
                        read_data_internal(1 downto 0) <= lp36_status_i;
                    when others =>
                        read_data_internal <= (others => '0');  -- Default read value
                end case;
                read_valid <= '1';
            else
                read_valid <= '0';
            end if;
        end if;
    end process;

    -- Write access part
    process(avl_clk_i, avl_reset_i)
    begin
        if avl_reset_i = '1' then
            -- Reset all outputs
            led_o         <= (others => '0');
            parallel_we   <= '0';
            parallel_sel  <= (others => '0');
            parallel_data <= (others => '0');
        elsif rising_edge(avl_clk_i) then
            if avl_write_i = '1' then
                case decoded_address is
                    when x"010004" =>  -- DE1-SoC Buttons (4 Keys)
                        buttons <= avl_writedata_i(3 downto 0);
                    when x"010008" =>  -- DE1-SoC Switches (10 Switches)
                        switches <= avl_writedata_i(9 downto 0);
                    when x"01000C" to x"01001F" =>  -- DE1-SoC LEDs (10 LEDs)
                        leds <= avl_writedata_i(9 downto 0);
                    when x"010020" to x"01002F" =>  -- Max10 LEDs (Parallel Interface)
                        parallel_we <= '1';
                        parallel_sel <= avl_writedata_i(3 downto 0); -- Select LED group
                        parallel_data <= avl_writedata_i;  -- Write data to Max10 LEDs
                    when others =>
                        parallel_we <= '0';  -- Disable write for unknown addresses
                end case;
            end if;
        end if;
    end process;

    -- Interface management
    process(avl_clk_i)
    begin
        if rising_edge(avl_clk_i) then
            if parallel_we = '1' then
                -- Send data to Max10 LEDs
                lp36_we_o   <= '1';
                lp36_sel_o  <= parallel_sel;
                lp36_data_o <= parallel_data;
            else
                lp36_we_o   <= '0';
                lp36_sel_o  <= (others => '0');
                lp36_data_o <= (others => '0');
            end if;
        end if;
    end process;
    
        -- Multiplexer Process: Handles selection of peripheral based on address
        process(avl_address_i)
        begin
            case avl_address_i is
                when x"010000" => 
                    decoded_address <= x"010000";  -- User ID access
                when x"010004" =>
                    decoded_address <= x"010004";  -- Button access
                when x"010008" =>
                    decoded_address <= x"010008";  -- Switch access
                when x"01000C" to x"01001F" =>
                    decoded_address <= x"01000C";  -- LED access
                when x"010020" to x"01002F" =>
                    decoded_address <= x"010020";  -- Max10 LED access
                when others =>
                    decoded_address <= (others => '0'); -- Default case
            end case;
        end process;
    
        -- Decoder Process: Decodes the address and sends it to appropriate process
        process(avl_address_i)
        begin
            -- Based on decoded address, the relevant signals will be controlled
            case decoded_address is
                when x"010000" =>  -- User ID
                    read_data_internal <= user_id;
                when x"010004" =>  -- Buttons
                    read_data_internal(3 downto 0) <= boutton_i;
                when x"010008" =>  -- Switches
                    read_data_internal(9 downto 0) <= switch_i;
                when x"01000C" =>  -- LEDs
                    led_o <= avl_writedata_i(9 downto 0);
                when x"010020" =>  -- Max10 LEDs
                    lp36_we_o <= avl_write_i;
                    lp36_sel_o <= avl_writedata_i(3 downto 0);
                when others =>
                    -- Default case, do nothing
                    lp36_we_o <= '0';
            end case;
        end process;
    
        -- Output the read data and read valid signal
        avl_readdatavalid_o <= read_valid;
        avl_readdata_o      <= read_data_internal;
    
        -- Waitrequest is not used
        avl_waitrequest_o <= '0';
end rtl; 