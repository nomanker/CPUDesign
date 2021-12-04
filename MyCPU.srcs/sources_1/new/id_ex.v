`timescale 1ns / 1ps
`include "defines.v"
module id_ex(
    input wire clk,
    input wire rst,
    //从译码阶段传递过来的信息
    input wire[`AluOpBus] id_aluop,
    input  wire[`RegBus] id_reg1,
    input  wire[`RegBus] id_reg2,
    input wire[`RegAddrBus] id_wd, 
    input  wire id_wreg, 
    input wire[`RegBus] id_inst,//来自ID模块的信号
    
    //传递到执行阶段的信息
    output reg[`AluOpBus] ex_aluop,
    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg,
    output reg[`RegBus] ex_inst //传递到EX模块的信号
    );

    always @(posedge clk) begin
        if (rst ==`RstEnable) begin
            ex_aluop <= `NOP_OP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_inst <= `ZeroWord;
        end else begin
            ex_aluop <= id_aluop;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
            ex_inst <= id_inst;
        end
    end
endmodule
