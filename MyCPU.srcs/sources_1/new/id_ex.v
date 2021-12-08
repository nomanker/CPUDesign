`timescale 1ns / 1ps
`include "defines.v"
module id_ex(
    input wire clk,
    input wire rst,

    //来自控制模块的信息
	input wire[5:0]							 stall,

    //从译码阶段传递过来的信息
    input wire[`AluOpBus] id_aluop,
    input  wire[`RegBus] id_reg1,
    input  wire[`RegBus] id_reg2,
    input wire[`RegAddrBus] id_wd, 
    input  wire id_wreg, 
    input wire[`RegBus] id_inst,//来自ID模块的信号

    //跳转指令新增
	input wire[`RegBus]           id_link_address,
	input wire                    id_is_in_delayslot,
	input wire                    next_inst_in_delayslot_i,	

    
    //传递到执行阶段的信息
    output reg[`AluOpBus] ex_aluop,
    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg,
    output reg[`RegBus] ex_inst, //传递到EX模块的信号

    //跳转指令新增输出
    output reg[`RegBus]           ex_link_address,
    output reg                    ex_is_in_delayslot,
	output reg                    is_in_delayslot_o	
    );

    always @(posedge clk) begin
        if (rst ==`RstEnable) begin
            ex_aluop <= `NOP_OP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_inst <= `ZeroWord;
            ex_link_address <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
	        is_in_delayslot_o <= `NotInDelaySlot;			
        end else if(stall[2] == `Stop && stall[3] == `NoStop) begin
			ex_aluop <= `NOP_OP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;	
			ex_link_address <= `ZeroWord;
	        ex_is_in_delayslot <= `NotInDelaySlot;	
	        ex_inst <= `ZeroWord;			
		end else if(stall[2]==`NoStop) begin
            ex_aluop <= id_aluop;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
            //lw和sw
            ex_inst <= id_inst;
            //跳转指令
            ex_link_address <= id_link_address;
			ex_is_in_delayslot <= id_is_in_delayslot;
	        is_in_delayslot_o <= next_inst_in_delayslot_i;
        end
    end
endmodule
