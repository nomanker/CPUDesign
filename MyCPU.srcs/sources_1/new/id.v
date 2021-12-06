`timescale 1ns / 1ps
`include "defines.v"
module id(
           input wire rst,
           //pc传过来的指令地址
           input wire[`InstAddrBus]			pc_i,

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
           //增加的新信号,存储需要
           output wire[`RegBus] inst_o,
           //表示是否是延迟槽指令
           input wire is_in_delayslot_i,

           output reg next_inst_in_delayslot_o,
           output reg branch_flag_o,
           output reg[`RegBus] branch_target_address_o,
           output reg[`RegBus] link_addr_o,
           output reg  is_in_delayslot_o
       );
wire[5:0] op= inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];
reg[`RegBus] imm;
reg instvalid;

//inst_o的值就是译码阶段的指令
assign inst_o = inst_i;


//跳转指令
wire [`RegBus] pc_plus_8;
wire [`RegBus] pc_plus_4;

wire[`RegBus] imm_sll2_signedext;

assign pc_plus_8 =pc_i+8;
assign pc_plus_4 = pc_i+4;
 assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00 };  


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
        link_addr_o <= `ZeroWord;
		branch_target_address_o <= `ZeroWord;
		branch_flag_o <= `NotBranch;
		next_inst_in_delayslot_o <= `NotInDelaySlot;	
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

        //跳转指令新增初始化
        link_addr_o <= `ZeroWord;
		branch_target_address_o <= `ZeroWord;
		branch_flag_o <= `NotBranch;	
		next_inst_in_delayslot_o <= `NotInDelaySlot;
        
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
                            //新增跳转指令
                            `EXE_JR: begin
                                wreg_o <= `WriteDisable;
                                aluop_o <= `JR_OP;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b0;
                                link_addr_o <= `ZeroWord;

                                branch_target_address_o <= reg1_o;
                                branch_flag_o <= `Branch;

                                next_inst_in_delayslot_o <= `InDelaySlot;
                                instvalid <= `InstValid;
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
            //新增跳转指令
            `EXE_JAL:	begin
                wreg_o <= `WriteEnable;
                aluop_o <= `JAL_OP;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b0;
                wd_o <= 5'b11111;
                link_addr_o <= pc_plus_8 ;
                branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                branch_flag_o <= `Branch;
                next_inst_in_delayslot_o <= `InDelaySlot;
                instvalid <= `InstValid;
            end
            `EXE_BEQ:	begin
                wreg_o <= `WriteDisable;
                aluop_o <= `BEQ_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b1;
                instvalid <= `InstValid;
                if(reg1_o == reg2_o) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                end
            end
             `EXE_BNE:	begin
                wreg_o <= `WriteDisable;
                aluop_o <= `BNE_OP;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b1;
                instvalid <= `InstValid;
                if(reg1_o != reg2_o) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Branch;
                    next_inst_in_delayslot_o <= `InDelaySlot;
                end
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
