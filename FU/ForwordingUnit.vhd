LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY ForwardingUnit IS
    PORT (
        current_op1_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        current_op2_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        last_WB             : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        last_Rd             : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        before_last_WB      : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        before_last_Rd      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        op1_mux             : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        op2_mux             : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        mux_10_sel          : IN STD_LOGIC);

END ForwardingUnit;
ARCHITECTURE arch OF ForwardingUnit IS
    SIGNAL op1_equal_last        : STD_LOGIC;
    SIGNAL op1_equal_before_last : STD_LOGIC;
    SIGNAL op1_equal_both        : STD_LOGIC;
    SIGNAL op2_equal_last        : STD_LOGIC;
    SIGNAL op2_equal_before_last : STD_LOGIC;
    SIGNAL op2_equal_both        : STD_LOGIC;
BEGIN
    op1_equal_last <= '1' WHEN
        current_op1_address = last_Rd
        ELSE
        '0';
    op1_equal_before_last <= '1' WHEN
        current_op1_address = before_last_Rd
        ELSE
        '0';
    op1_equal_both <= '1' WHEN
        op1_equal_last = '1' AND op1_equal_before_last = '1'
        ELSE
        '0';

    op2_equal_last <= '1' WHEN
        current_op2_address = last_Rd
        ELSE
        '0';
    op2_equal_before_last <= '1' WHEN
        current_op2_address = before_last_Rd
        ELSE
        '0';
    op2_equal_both <= '1' WHEN
        op2_equal_last = '1' AND op2_equal_before_last = '1'
        ELSE
        '0';

    op1_mux <= "01" WHEN op1_equal_both = '1' AND last_WB = "10"
        ELSE
        "10" WHEN op1_equal_both = '1'
        ELSE
        "01" WHEN op1_equal_last = '1' AND last_WB = "10"
        ELSE
        "10" WHEN op1_equal_last = '1' AND last_WB = "11"
        ELSE
        "10" WHEN op1_equal_before_last = '1'AND before_last_WB = "10"
        ELSE
        "10" WHEN op1_equal_before_last = '1'AND before_last_WB = "11"
        ELSE
        "00";
    op2_mux <= "00" WHEN mux_10_sel='1'
        ELSE
        "01" WHEN op2_equal_both = '1' AND last_WB = "10"
        ELSE
        "10" WHEN op2_equal_both = '1'
        ELSE
        "01" WHEN op2_equal_last = '1' AND last_WB = "10"
        ELSE
        "10" WHEN op2_equal_last = '1' AND last_WB = "11"
        ELSE
        "10" WHEN op2_equal_before_last = '1'AND before_last_WB = "10"
        ELSE
        "10" WHEN op2_equal_before_last = '1'AND before_last_WB = "11"
        ELSE
        "00";
END ARCHITECTURE;