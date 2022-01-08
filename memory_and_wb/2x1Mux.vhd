--generic 2x1 Mux
--Library
Library ieee;
use ieee.std_logic_1164.all;
--Entity
ENTITY mux2x1 IS
GENERIC (n : integer := 8);
PORT( in0,in1: IN std_logic_vector (n-1 DOWNTO 0);
              sel : IN std_logic;
              out_mux: OUT std_logic_vector (n-1 DOWNTO 0));
END mux2x1;

--Architecture
ARCHITECTURE  arch_mux2x1 OF mux2x1 IS
BEGIN
     	out_mux <= in0 
	WHEN sel = '0'
	ELSE in1 WHEN sel = '1';

END arch_mux2x1;

--end mux part
