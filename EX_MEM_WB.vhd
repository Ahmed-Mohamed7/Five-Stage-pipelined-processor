library IEEE;
use IEEE.std_logic_1164.all;
ENTITY EX_MEM_WB IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        memValuein : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        memAddressin : IN STD_LOGIC;
        PCin : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        nextPCin : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        SPOPin : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        SPNUMin : IN STD_LOGIC;
        WBin : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        MEM : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        EX : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        RSdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        secondOperand : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        RTIin : IN STD_LOGIC;
        BackupFlag : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        rdAddressin : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        rsAddress : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        rtAddress : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        RETin : IN STD_LOGIC;
        EXflush : IN STD_LOGIC;
        flush_mem_Wb : IN STD_LOGIC;
	-- from control unit
	out_port_en: IN STD_LOGIC;
        -- Outputs
        -- 
        -- output of mux 4
	rd_data: OUT std_logic_vector ( 15 downto 0);
	-- from alu result data
	output_port: OUT std_logic_vector ( 15 downto 0)
    );
END EX_MEM_WB;

ARCHITECTURE arch OF EX_MEM_WB IS
    COMPONENT memory_stage IS
        PORT (
            ------ inputs ------
            clk : IN STD_LOGIC;
            -- for flushing the write back stage
            flush_mem_Wb : IN STD_LOGIC;
            --for resetting the cache
            reset : IN STD_LOGIC;
            -- Mux 12 selector : to choose which data to input to the chache
            mem_value : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            -- Mux 13 selector : to choose between data memory and stack memory
            mem_address : IN STD_LOGIC;
            -- pc+1 (input to mux 12): to enter the stack memory whenever an interrupt or Call occurs
            next_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- writeback(2 bits): first bit (1) to indicate if the wb is enabled or not, 
            -- second bit (0)(mux 14 selector) to choose whether to write back the alu result or the memory output
            wb : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            -- memory read enable
            mem_read : IN STD_LOGIC;
            -- memory write enable
            mem_write : IN STD_LOGIC;
            -- stack adder/sub input to choose to pop or push (add or sub)
            -- sp[1] -> mux 16, sp[0] -> alu/sun
            sp_op : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            -- Mux 11 selector : to choose to add/sub 2 or 1 to the sp
            sp_num : IN STD_LOGIC;
            -- input to mux 12: to enter the memory
            r_src1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- input to mux 12: to enter the memory
            alu_res : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- ret interrupt enable
            rti : IN STD_LOGIC;
            -- ret from call enable
            ret : IN STD_LOGIC;
            -- pc (input to exception pc): if an exception occurs, we save it to the epc
            pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- rd address: the destination register, to enter the forwarding unit
            rd_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ---------------------

            ------ outputs ------
            -- incication of enabling the wb
            wb_en : OUT STD_LOGIC;
            -- mux 14 selector
            --to choose whether to write back the alu result or the memory output
            alu_mem_output : OUT STD_LOGIC;
            -- input to mux 14: to be writed back
            -- input to output port
            alu_res_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- memory output
            mem : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- ret interrupt enable
            rti_output : OUT STD_LOGIC;
            -- ret from call enable
            ret_output : OUT STD_LOGIC;
            -- rd address: the destination register, to enter the forwarding unit
            rd_address_output : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	    
        );
    END COMPONENT;

    COMPONENT write_back_stage IS
        PORT (
            clk : IN STD_LOGIC;
            out_port_en : IN STD_LOGIC;
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
            input : IN STD_LOGIC_VECTOR(38 DOWNTO 0);
            -- output of mux 4
            rd_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            -- from alu result data
            output_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ExecutionStage IS
        PORT (
            -- Inputs
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            memValuein : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            memAddressin : IN STD_LOGIC;
            PCin : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            nextPCin : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            SPOPin : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            SPNUMin : IN STD_LOGIC;
            WBin : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            MEM : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            EX : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            RSdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            secondOperand : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            RTIin : IN STD_LOGIC;
            BackupFlag : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            rdAddressin : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            rsAddress : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            rtAddress : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            RETin : IN STD_LOGIC;
            EXflush : IN STD_LOGIC;

            -- Outputs
            memValueout : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            memAddressout : OUT STD_LOGIC;
            nextPCout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            WBout : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            MemRe : OUT STD_LOGIC;
            MemWr : OUT STD_LOGIC;
            SPOPout : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            SPNUMout : OUT STD_LOGIC;
            Rsrc1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            RTIout : OUT STD_LOGIC;
            RETout : OUT STD_LOGIC;
            PCout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            rdAddressout : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            -- ALU
            ALUres : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            -- jump
            jumpAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    SIGNAL memValueout :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL memAddressout :  STD_LOGIC;
    SIGNAL nextPCout :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WBout :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL MemRe :  STD_LOGIC;
    SIGNAL MemWr :  STD_LOGIC;
    SIGNAL SPOPout :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL SPNUMout :  STD_LOGIC;
    SIGNAL Rsrc1 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL RTIout :  STD_LOGIC;
    SIGNAL RETout :  STD_LOGIC;
    SIGNAL PCout :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL rdAddressout :  STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ALUres :  STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL flags :  STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL jumpAddress :  STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL wb_en :  STD_LOGIC;
    SIGNAL alu_mem_output :  STD_LOGIC;
    SIGNAL alu_res_out :  STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL mem_out :  STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rti_output :  STD_LOGIC;
    SIGNAL ret_output :  STD_LOGIC;
    SIGNAL rd_address_output :  STD_LOGIC_VECTOR(2 DOWNTO 0);

    SIGNAL wb_input: STD_LOGIC_VECTOR(38 DOWNTO 0);
   

BEGIN
	

EX_Stage : ExecutionStage PORT MAP(
	clk, 
	reset, memValuein, memAddressin, 
	PCin, nextPCin, SPOPin, 
	SPNUMin, WBin, MEM, EX, 
	RSdata, secondOperand, RTIin, 
	BackupFlag, rdAddressin, rsAddress, 
	rtAddress, RETin, EXflush, 
	memValueout, memAddressout, 
	nextPCout, WBout, MemRe, MemWr, 
	SPOPout, SPNUMout, Rsrc1, RTIout, RETout, 
	PCout, rdAddressout, ALUres, flags, jumpAddress);

MEM_Stage : memory_stage PORT MAP(
        clk, flush_mem_Wb, reset, memValueout, 
	memAddressout, nextPCout, WBout, MemRe, 
	MemWr, SPOPout, SPNUMout, Rsrc1, ALUres, 
	RTIout, RETout, PCout, rdAddressout,
        -- Outputs
        wb_en,
        alu_mem_output,
        alu_res_out,
        mem_out,
        rti_output,
        ret_output,
        rd_address_output);

    wb_input(38)<=wb_en;
    wb_input(37)<=alu_mem_output;
    wb_input(36 downto 21)<=alu_res_out;
    wb_input(20 downto 5)<=mem_out;
    wb_input(4)<=rti_output;
    wb_input(3)<=ret_output;
    wb_input(2 downto 0)<=rd_address_output;

WB_Stage : write_back_stage PORT MAP(
	-- inputs
        clk,
	out_port_en,
	wb_input,
	-- output 
	rd_data,
	output_port
        );

    

END ARCHITECTURE;