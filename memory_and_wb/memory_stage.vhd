library IEEE;
use IEEE.std_logic_1164.all;

ENTITY memory_stage IS
port(
	------ inputs ------
	clk: in std_logic;
	-- for flushing the write back stage
	flush_mem_Wb: in std_logic;
	--for resetting the cache
	reset: in std_logic; 
	-- Mux 12 selector : to choose which data to input to the chache
	mem_value: in std_logic_vector(1 downto 0);
	-- Mux 13 selector : to choose between data memory and stack memory
	mem_address: in std_logic; 
	-- pc+1 (input to mux 12): to enter the stack memory whenever an interrupt or Call occurs
	next_pc: in std_logic_vector(31 downto 0);
	-- writeback(2 bits): first bit (1) to indicate if the wb is enabled or not, 
	-- second bit (0)(mux 14 selector) to choose whether to write back the alu result or the memory output
	wb: in std_logic_vector(1 downto 0);
	-- memory read enable
	mem_read: in std_logic;
	-- memory write enable
	mem_write: in std_logic;
	-- stack adder/sub input to choose to pop or push (add or sub)
	sp_op: in std_logic;
	-- Mux 11 selector : to choose to add/sub 2 or 1 to the sp
	sp_num: in std_logic;
	-- input to mux 12: to enter the memory
	r_src1: in std_logic_vector(15 downto 0);
	-- input to mux 12: to enter the memory
	alu_res: in std_logic_vector(15 downto 0);
	-- ret interrupt enable
	rti: in std_logic;
	-- ret from call enable
	ret: in std_logic;
	-- pc (input to exception pc): if an exception occurs, we save it to the epc
	pc: in std_logic_vector(31 downto 0);
	-- rd address: the destination register, to enter the forwarding unit
	rd_address: in std_logic_vector(2 downto 0);
	---------------------

	------ outputs ------
	-- incication of enabling the wb
	wb_en: out std_logic;
	-- mux 14 selector
	--to choose whether to write back the alu result or the memory output
	alu_mem_output: out std_logic;
	-- input to mux 14: to be writed back
	-- input to output port
	alu_res_out: out std_logic_vector(15 downto 0);
	-- memory output
	mem: out std_logic_vector(15 downto 0);
	-- ret interrupt enable
	rti_output: out std_logic;
	-- ret from call enable
	ret_output: out std_logic;
	-- rd address: the destination register, to enter the forwarding unit
	rd_address_output: out std_logic_vector(2 downto 0)
);
END memory_stage;

ARCHITECTURE mem_arch of memory_stage IS
Component mem_wb_buffer IS

PORT (
        flush : IN STD_LOGIC;
	clk: IN STD_LOGIC;
	------ INPUTS Description------
	-- incication of enabling the wb
	-- INPUT[38]-> wb_en: IN std_logic;
	-- mux 14 selector
	--to choose whether to write back the alu result or the memory output
	-- INPUT[37]-> alu_mem: IN std_logic;
	-- input to mux 14: to be writed back
	-- input to output port
	-- INPUT[36: 21]-> alu_res: IN std_logic_vector(15 downto 0);
	-- memory output
	-- INPUT[20: 5]-> mem: IN std_logic_vector(15 downto 0);
	-- ret interrupt enable
	-- INPUT[4]-> rti: IN std_logic;
	-- ret from call enable
	-- INPUT[3]-> ret: in std_logic;
	-- rd address: the destination register, to enter the forwarding unit
	-- INPUT[2:0]-> rd_address_output: in std_logic_vector(2 downto 0);
	input: IN std_logic_vector( 38 downto 0 );
        output : OUT std_logic_vector( 38 downto 0 ));
END Component;
---- Signals ----
SIGNAL q: std_logic_vector(38 downto 0); -- buffer input
SIGNAL d: std_logic_vector(38 downto 0); -- buffer output
BEGIN
	-- writing to the mem/wb buffer
	q(38 downto 37)<= wb;
	q(36 downto 21)<= alu_res;
	q(20 downto 5)<= (others=>'0'); -- TODO :: replace this with memory output
	q(4)<= rti; 
	q(3)<= ret;
	q(2 downto 0)<= rd_address;
	-- getting output of the mem/wb buffer
	wb_en<= d(38);
	alu_mem_output<= d(37);
	alu_res_out<= d(36 downto 21);
	mem<= d(20 downto 5);
	rti_output <= d(4);
	ret_output <= d(3);
	rd_address_output <= d(2 downto 0);
	-- connecting to the mem_wb buffer
	mem_wb_buff: mem_wb_buffer PORT MAP(flush_mem_Wb,clk,q, d);


	
	
END mem_arch;

