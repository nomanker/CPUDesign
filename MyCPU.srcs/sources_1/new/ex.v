`timescale 1ns / 1ps
`include "defines.v"
module ex(
           input wire rst,
           input [`AluOpBus] alu_control,
           input [`RegBus] alu_src1,
           input [`RegBus] alu_src2,
           //新增输入接口inst_i,他的值就是当前处于执行阶段的指令
           input wire[`RegBus]    inst_i,

           output reg[`RegBus] alu_result,
           output reg[`RegAddrBus] wd_o,
           output reg wreg_o,
           input  wire wreg_i,
           input wire[`RegAddrBus] wd_i,

           //下面新增的几个输出接口时为了加载，存储指令准备的
           output wire[`AluOpBus] aluop_o,
           output wire[`RegBus]  mem_addr_o,
           output wire[`RegBus]  reg2_o
       );
wire[`RegBus] alu_src2_mux;
wire[`RegBus] result_sum;
wire src1_lt_src2;
assign alu_src2_mux = ((alu_control==`SUB_OP)||(alu_control==`SLT_OP)||(alu_control==`SUBU_OP))?(~alu_src2)+1:alu_src2;
assign result_sum = alu_src1+alu_src2_mux;
assign src1_lt_src2=(alu_control==`SLT_OP)?((alu_src1[31]&&!alu_src2[31])
        ||!alu_src1[31]&&!alu_src2[31]&&result_sum[31]
        ||alu_src1[31]&&alu_src2[31]&&result_sum[31])
       :(alu_src1<alu_src2);
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
    end
    else begin
        wd_o=wd_i;
        wreg_o=wreg_i;
        case(alu_control)
            `ADD_OP,`SUB_OP,`ADDU_OP,`SUBU_OP,`ADDIU_OP: begin
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
            default: begin
                alu_result<=`ZeroWord;
            end
        endcase
    end
end
endmodule
