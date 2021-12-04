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
//alu
`define AluOpBus 4:0

//alu_op
`define ADD_OP   5'b00000
`define SUB_OP   5'b00001
`define SLT_OP   5'b00010
`define SLTU_OP  5'b00011
`define AND_OP   5'b00100
`define NOR_OP   5'b00101
`define OR_OP    5'b00110
`define XOR_OP   5'b00111
`define SLL_OP   5'b01000
`define SRL_OP   5'b01001
`define SRA_OP   5'b01010
`define LUI_OP   5'b01011
`define ADDU_OP  5'b01100
`define SUBU_OP  5'b01101
`define ADDIU_OP 5'b01110
`define NOP_OP   5'b01111
`define LW_OP   5'b10000
`define SW_OP   5'b10001

//指令=====操作码

`define EXE_AND 6'b100100
`define EXE_OR 6'b100101
`define EXE_XOR 6'b100110
`define EXE_NOR 6'b100111
`define EXE_LUI 6'b001111

`define EXE_SLL 6'b000_000
`define EXE_SRL 6'b000_010
`define EXE_SRA 6'b000_011

`define EXE_SLT 6'b101_010
`define EXE_SLTU 6'b101_011

`define EXE_ADD 6'b100_000
`define EXE_ADDU 6'b100_001
//lw和sw指令
`define EXE_LW 6'b100_011
`define EXE_SW 6'b101_011

`define EXE_ADDIU 6'b001_001
`define EXE_SUB 6'b100_010
`define EXE_SUBU 6'b100_011
`define EXE_SPECIAL_INST 6'b000_000
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
