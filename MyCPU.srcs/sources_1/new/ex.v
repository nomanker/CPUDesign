`timescale 1ns / 1ps
`include "defines.v"
module ex(
           input wire rst,
           input [`AluOpBus] alu_control,
           input [`RegBus] alu_src1,
           input [`RegBus] alu_src2,
           output reg[`RegBus] alu_result,
           output reg[`RegAddrBus] wd_o,
           output reg wreg_o,
           input  wire wreg_i,
           input wire[`RegAddrBus] wd_i
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
