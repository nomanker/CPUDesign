`timescale 1ns / 1ps
`include"defines.v"
module ex_mem(
    input  wire clk,
    input wire rst,
    //来自执行阶段的信息
    input wire[`RegAddrBus] ex_wd,
    input  wire ex_wreg,
    input  wire[`RegBus] ex_wdata,
    //为实现加载，存储指令而添加的输入接口
    input wire[`AluOpBus] ex_aluop,
    input wire[`RegBus] ex_mem_addr,
    input wire[`RegBus] ex_reg2,
    //为实现加载，存储指令而添加的输出接口
    output reg[`AluOpBus] mem_aluop,
    output reg[`RegBus] mem_mem_addr,
    output reg[`RegBus] mem_reg2,
    //送到访存阶段的信息
    output reg [`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_wdata 
    );

    always @(posedge clk) begin
        if (rst==`RstEnable) begin
            mem_wd = `NOPRegAddr;
            mem_wreg = `WriteDisable;
            mem_wdata = `ZeroWord;
            mem_aluop <= `NOP_OP;
            mem_mem_addr <= `ZeroWord;
            mem_reg2 <= `ZeroWord;
        end else begin
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            mem_aluop <= ex_aluop;
            mem_mem_addr <= ex_mem_addr;
            mem_reg2 <= ex_reg2;
        end
    end
endmodule
