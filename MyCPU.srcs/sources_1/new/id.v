`timescale 1ns / 1ps
`include "defines.v"
module id(
           input wire rst,
           input wire[`InstBus]  inst_i,
           input wire[`RegBus] reg1_data_i,
           input wire[`RegBus] reg2_data_i,
           //发送到regfile的信息
           output reg    reg1_read_o,
           output reg    reg2_read_o,
           output reg[`RegAddrBus] reg1_addr_o,
           output reg[`RegAddrBus] reg2_addr_o,
           //发送到执行阶段的信息
           output reg[`AluOpBus] aluop_o,
           output reg[`RegBus] reg1_o,
           output reg[`RegBus] reg2_o,
           output reg[`RegAddrBus] wd_o,
           output reg   wreg_o,
           //增加的新信号
           output wire[`RegBus] inst_o
       );
wire[5:0] op= inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];
reg[`RegBus] imm;
reg instvalid;

//inst_o的值就是译码阶段的指令
assign inst_o = inst_i;

always @(*) begin
    // 复位信号有效，代表机器是关机的状态
    if(rst==`RstEnable) begin
        aluop_o<=  `NOP_OP;
        wd_o<=`NOPRegAddr;
        wreg_o<=`WriteDisable;
        instvalid<=`InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <=32'h0;
    end
    else begin
        // 这时候代表机器是开机的状态
        aluop_o<= `NOP_OP;
        wd_o<=inst_i[15:11];
        wreg_o<=`WriteDisable;
        instvalid<=`InstInvalid;
        reg1_read_o <=1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o<=inst_i[25:21];
        reg2_addr_o<=inst_i[20:16];
        imm<= `ZeroWord;
        case(op)
            `EXE_SPECIAL_INST: begin
                case(op2)
                    5'b0_0000: begin
                        case(op3)
                            `EXE_OR: begin
                                wreg_o<=`WriteEnable;
                                aluop_o<=`OR_OP;
                                reg1_read_o<=1'b1;
                                reg2_read_o<=1'b1;
                                instvalid<=`InstValid;
                            end
                            `EXE_AND: begin
                                wreg_o <=`WriteEnable;
                                aluop_o<=`AND_OP;
                                reg1_read_o<=1'b1;
                                reg2_read_o <=1'b1;
                                instvalid<=`InstValid;
                            end
                            `EXE_XOR: begin
                                wreg_o<=`WriteEnable;
                                aluop_o<= `XOR_OP;
                                reg1_read_o<=1'b1;
                                reg2_read_o <=1'b1;
                                instvalid<= `InstValid;
                            end
                            `EXE_NOR: begin
                                wreg_o<=`WriteEnable;
                                aluop_o<= `NOR_OP;
                                reg1_read_o<=1'b1;
                                reg2_read_o <=1'b1;
                                instvalid<= `InstValid;
                            end
                            `EXE_SLT: begin
                                wreg_o<=`WriteEnable;
                                aluop_o<= `SLT_OP;
                                reg1_read_o<=1'b1;
                                reg2_read_o <=1'b1;
                                instvalid<= `InstValid;
                            end
                            `EXE_SLTU: begin
                                wreg_o<=`WriteEnable;
                                aluop_o<= `SLTU_OP;
                                reg1_read_o<=1'b1;
                                reg2_read_o <=1'b1;
                                instvalid<= `InstValid;
                            end
                            `EXE_ADD: begin
                                wreg_o<=`WriteEnable;
                                aluop_o<= `ADD_OP;
                                reg1_read_o<=1'b1;
                                reg2_read_o <=1'b1;
                                instvalid<= `InstValid;
                            end
                            `EXE_ADDU: begin
                                wreg_o<=`WriteEnable;
                                aluop_o<= `ADDU_OP;
                                reg1_read_o<=1'b1;
                                reg2_read_o <=1'b1;
                                instvalid<= `InstValid;
                            end
                            `EXE_SUB: begin
                                wreg_o<=`WriteEnable;
                                aluop_o<= `SUB_OP;
                                reg1_read_o<=1'b1;
                                reg2_read_o <=1'b1;
                                instvalid<= `InstValid;
                            end
                            `EXE_SUBU: begin
                                wreg_o<=`WriteEnable;
                                aluop_o<= `SUBU_OP;
                                reg1_read_o<=1'b1;
                                reg2_read_o <=1'b1;
                                instvalid<= `InstValid;
                            end
                            default: begin
                            end
                        endcase //endcase op3
                    end
                    default: begin
                    end
                endcase
            end
            `EXE_LUI: begin
                wreg_o<=`WriteEnable;
                aluop_o<= `OR_OP;
                reg1_read_o<=1'b1;
                reg2_read_o <=1'b0;
                imm<={inst_i[15:0],16'h0};
                wd_o<=inst_i[20:16];
                instvalid<= `InstValid;
            end
            `EXE_ADDIU:begin
                wreg_o <= `WriteEnable;
                aluop_o <= `ADDIU_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end
            `EXE_LW:begin
                wreg_o <= `WriteEnable;
                aluop_o <= `LW_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end

            `EXE_SW:begin
                wreg_o <= `WriteDisable;
                aluop_o <= `SW_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b1;
                instvalid <= `InstValid;
            end
            default: begin
            end
        endcase //case op
        if(inst_i[31:21]==11'b000_0000_0000) begin
            if(op3==`EXE_SLL) begin
                wreg_o<=`WriteEnable;
                aluop_o<= `SLL_OP;
                reg1_read_o<=1'b0;
                reg2_read_o <=1'b1;
                imm[4:0]<=inst_i[10:6];
                wd_o<=inst_i[15:11];
                instvalid<= `InstValid;
            end
            else if(op3==`EXE_SRL) begin
                wreg_o<=`WriteEnable;
                aluop_o<= `SRL_OP;
                reg1_read_o<=1'b0;
                reg2_read_o <=1'b1;
                imm[4:0]<=inst_i[10:6];
                wd_o<=inst_i[15:11];
                instvalid<= `InstValid;
            end
            else if(op3==`EXE_SRA) begin
                wreg_o<=`WriteEnable;
                aluop_o<= `SRA_OP;
                reg1_read_o<=1'b0;
                reg2_read_o <=1'b1;
                imm[4:0]<=inst_i[10:6];
                wd_o<=inst_i[15:11];
                instvalid<= `InstValid;
            end
        end



    end//end if(rst==Rst)
end  //always
always @(*) begin
    if(rst==`RstEnable) begin
        reg1_o<=`ZeroWord;
    end
    else if(reg1_read_o==1'b1) begin
        reg1_o<=reg1_data_i;
    end
    else if(reg1_read_o==1'b0) begin
        reg1_o<=imm;
    end
    else begin
        reg1_o<=`ZeroWord;
    end
end

always @(*) begin
    if(rst==`RstEnable) begin
        reg2_o<=`ZeroWord;
    end
    else if(reg2_read_o==1'b1) begin
        reg2_o<=reg2_data_i;
    end
    else if(reg2_read_o==1'b0) begin
        reg2_o<=imm;
    end
    else begin
        reg2_o<=`ZeroWord;
    end
end
endmodule
