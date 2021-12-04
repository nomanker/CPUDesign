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
`define AluOpBus 3:0

//alu_op
`define ADD_OP 4'b0000
`define SUB_OP 4'b0001
`define SLT_OP 4'b0010
`define SLTU_OP 4'b0011
`define AND_OP 4'b0100
`define NOR_OP 4'b0101
`define OR_OP 4'b0110
`define XOR_OP 4'b0111
`define SLL_OP 4'b1000
`define SRL_OP 4'b1001
`define SRA_OP 4'b1010
`define LUI_OP 4'b1011
`define ADDU_OP 4'b1100
`define SUBU_OP 4'b1101
`define ADDIU_OP 4'b1110
`define NOP_OP 4'b1111

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
`define AluOpBus 3:0


