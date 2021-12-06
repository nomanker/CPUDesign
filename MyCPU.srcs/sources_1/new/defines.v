`define ChipEnable 1'b1
`define ChipDisable 1'b0
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 7:0

`define RegBus 31:0
`define RstEnable 1'b1
`define RstDisable 1'b0

//全局，分支跳转
`define Branch 1'b1
`define NotBranch 1'b0
//是否是延迟槽指令
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
//alu
`define AluOpBus 6:0

//alu_op
`define ADD_OP   6'b000000
`define SUB_OP   6'b000001
`define SLT_OP   6'b000010
`define SLTU_OP  6'b000011
`define AND_OP   6'b000100
`define NOR_OP   6'b000101
`define OR_OP    6'b000110
`define XOR_OP   6'b000111
`define SLL_OP   6'b001000
`define SRL_OP   6'b001001
`define SRA_OP   6'b001010
`define LUI_OP   6'b001011
`define ADDU_OP  6'b001100
`define SUBU_OP  6'b001101
`define ADDIU_OP 6'b001110
`define NOP_OP   6'b001111
`define LW_OP    6'b010000
`define SW_OP    6'b010001
//跳转操作码
`define BEQ_OP  6'b01001_0
`define BNE_OP  6'b01001_1
`define JAL_OP  6'b01010_0
`define JR_OP   6'b01010_1

//function2新增操作码
`define ADDI_OP  6'b01011_0
`define SLTI_OP  6'b01011_1
`define SLTIU_OP 6'b01100_0
`define ANDI_OP  6'b01100_1
`define ORI_OP   6'b01101_0
`define XORI_OP  6'b01101_1
`define SLLV_OP  6'b01110_0
`define SRAV_OP  6'b01110_1
`define SRLV_OP  6'b01111_0
`define DIV_OP   6'b01111_1
`define DIVU_OP  6'b10000_0
`define MULT_OP  6'b10000_1
`define MULTU_OP  6'b10001_0


//指令=====操作码

`define EXE_AND 6'b100100
`define EXE_OR 6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111
`define EXE_ANDI 6'b001100
`define EXE_ORI  6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111

`define EXE_SLL 6'b000_000
`define EXE_SLLV  6'b000100
`define EXE_SRL 6'b000_010
`define EXE_SRLV  6'b000110
`define EXE_SRA 6'b000_011
`define EXE_SRAV  6'b000111

`define EXE_SLT 6'b101_010
`define EXE_SLTU 6'b101_011
`define EXE_SLTI  6'b001010
`define EXE_SLTIU  6'b001011 

`define EXE_ADD 6'b100_000
`define EXE_ADDU 6'b100_001
//lw和sw指令
`define EXE_LW 6'b100_011
`define EXE_SW 6'b101_011
//分支跳转指令、BEQ、BNE、JAR、JR。
`define EXE_BEQ  6'b000100
`define EXE_BNE  6'b000101
`define EXE_JAL  6'b000011
`define EXE_JR  6'b001000


`define EXE_ADDIU 6'b001_001
`define EXE_SUB 6'b100_010
`define EXE_SUBU 6'b100_011
`define EXE_ADDI  6'b001000
`define EXE_SPECIAL_INST 6'b000_000

//乘法
`define EXE_MULT  6'b0011000
`define EXE_MULTU  6'b0011001

//全局
`define RstEnable 1'b1
`define RstDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0

//通用寄存器
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000

//通用指令存储器inst_rom
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131072
`define InstMemNumLog2 17

`define InstValid 1'b0
`define InstInvalid 1'b1
