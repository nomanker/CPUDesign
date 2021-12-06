`timescale 1ns / 1ps
`include "defines.v"
module ex(
           input wire rst,
           input [`AluOpBus] alu_control,
           input [`RegBus] alu_src1,
           input [`RegBus] alu_src2,
           //新增输入接口inst_i,他的值就是当前处于执行阶段的指令
           input wire[`RegBus]    inst_i,

           //是否转移、以及link address
           input wire[`RegBus]           link_address_i,
           input wire                    is_in_delayslot_i,

           output reg[`RegBus] alu_result,
           output reg[`RegAddrBus] wd_o,
           output reg wreg_o,
           input  wire wreg_i,
           input wire[`RegAddrBus] wd_i,

           //下面新增的几个输出接口时为了加载，存储指令准备的
           output wire[`AluOpBus] aluop_o,
           output wire[`RegBus]  mem_addr_o,
           output wire[`RegBus]  reg2_o,

           //增加高位寄存器和低位寄存器
           //HI、LO寄存器的值
           input wire[`RegBus]           hi_i,
           input wire[`RegBus]           lo_i,

           //回写阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
           input wire[`RegBus]           wb_hi_i,
           input wire[`RegBus]           wb_lo_i,
           input wire                    wb_whilo_i,

           //访存阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
           input wire[`RegBus]           mem_hi_i,
           input wire[`RegBus]           mem_lo_i,
           input wire                    mem_whilo_i,

           output reg[`RegBus]           hi_o,
           output reg[`RegBus]           lo_o,
           output reg                    whilo_o

       );
wire[`RegBus] alu_src2_mux;
wire[`RegBus] result_sum;//保存加法的结果
wire src1_lt_src2;
wire[`RegBus] reg1_i_not;//保存第一个操作数reg2_i的补码
wire[`RegBus] opdata1_mult;    //乘法操作中被乘数
wire[`RegBus] opdata2_mult;    //乘法操作中的乘数
wire[`DoubleRegBus] hilo_temp;   //临时保存乘法的结果，宽度为64位
reg[`DoubleRegBus] mulres;      //保存乘法的结果，宽度为64位

reg[`RegBus] HI;
reg[`RegBus] LO;


assign alu_src2_mux = ((alu_control==`SUB_OP)||(alu_control==`SLT_OP)||(alu_control==`SUBU_OP))?(~alu_src2)+1:alu_src2;
assign result_sum = alu_src1+alu_src2_mux;
assign src1_lt_src2=(alu_control==`SLT_OP)?((alu_src1[31]&&!alu_src2[31])
        ||!alu_src1[31]&&!alu_src2[31]&&result_sum[31]
        ||alu_src1[31]&&alu_src2[31]&&result_sum[31])
       :(alu_src1<alu_src2);
//对操作数1每位取反，赋值给reg1_i_not
assign reg1_i_not = ~alu_src1;

/*****************************乘法运算******************************
******************************************************************
**************************************************/
//取得乘法运算的被乘数，如果是有符号乘法，且被乘数是负数的话，那么取反加1
assign opdata1_mult = ((alu_control == `MULT_OP)&& (alu_src1[31] == 1'b1)) ? (~alu_src1 + 1) : alu_src1;
assign opdata2_mult = ((alu_control == `MULT_OP)&& (alu_src2[31] == 1'b1)) ? (~alu_src2 + 1) : alu_src2;
assign hilo_temp = opdata1_mult * opdata2_mult;
always @ (*) begin
    if(rst == `RstEnable) begin
        mulres <= {`ZeroWord,`ZeroWord};
    end
    else if ((alu_control == `MULT_OP)) begin
        if(alu_src1[31] ^ alu_src2[31] == 1'b1) begin
            mulres <= ~hilo_temp + 1;
        end
        else begin
            mulres <= hilo_temp;
        end
    end
    else begin
        mulres <= hilo_temp;
    end
end
//得到最新的HI、LO寄存器的值，此处要解决指令数据相关问题
always @ (*) begin
    if(rst == `RstEnable) begin
        {HI,LO} <= {`ZeroWord,`ZeroWord};
    end
    else if(mem_whilo_i == `WriteEnable) begin
        {HI,LO} <= {mem_hi_i,mem_lo_i};
    end
    else if(wb_whilo_i == `WriteEnable) begin
        {HI,LO} <= {wb_hi_i,wb_lo_i};
    end
    else begin
        {HI,LO} <= {hi_i,lo_i};
    end
end
//alupo_o回传递到访存阶段，届时将利用其确定加载，存储类型
assign aluop_o = alu_control;
//mem_addr_o 会传递到访存阶段，时加载，存储指令对应的存储器地址，此处的alu_src1就是加载，存储指令中地址为base的通用寄存器的值，inst_i[15:0]就是指令中
//的offset，通过mem_addr_o的计算
assign mem_addr_o = alu_src1 +{{16{inst_i[15]}},inst_i[15:0]};
//reg2_i 是存储指令要存储的数据
//将该值通过
assign reg2_o = alu_src2;


always @(*) begin
    if(rst==`RstEnable) begin
        alu_result=`ZeroWord;
        wd_o = `NOPRegAddr;
        wreg_o= `WriteDisable;
        whilo_o <=`WriteDisable;
        hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;
    end
    else begin
        wd_o=wd_i;
        wreg_o=wreg_i;
        case(alu_control)
            `ADD_OP,`SUB_OP,`ADDU_OP,`SUBU_OP,`ADDIU_OP,`ADDI_OP: begin
                alu_result<=result_sum;
            end
            `SLT_OP,`SLTU_OP: begin
                alu_result<=src1_lt_src2;
            end
            `AND_OP: begin
                alu_result<=alu_src1&alu_src2;
            end
            `NOR_OP: begin
                alu_result<=~(alu_src1|alu_src2);
            end
            `OR_OP: begin
                alu_result<=(alu_src1|alu_src2);
            end
            `XOR_OP: begin
                alu_result<=alu_src1^alu_src2;
            end
            `SLL_OP: begin
                alu_result<=alu_src2<<alu_src1[4:0];
            end
            `SRL_OP: begin
                alu_result<=alu_src2>>alu_src1[4:0];
            end
            `SRA_OP: begin
                alu_result<=({32{alu_src2[31]}}<<(6'd32-{1'b0,alu_src1[4:0]}))
                |alu_src2>>alu_src1[4:0];
            end
            `LUI_OP: begin
                alu_result<={alu_src2[15:0],16'd0};
            end
            `JAL_OP: begin
                alu_result <= link_address_i;
            end
            `MULT_OP,`MULTU_OP:begin
                whilo_o <= `WriteEnable;
                hi_o <= mulres[63:32];
			    lo_o <= mulres[31:0];	
            end
            default: begin
                alu_result<=`ZeroWord;
                whilo_o <=`WriteDisable;
                hi_o <= `ZeroWord;
		        lo_o <= `ZeroWord;
            end
        endcase
    end
end
endmodule
