`timescale 1ns / 1ps
`include"defines.v"
module ex_mem(
    input  wire clk,
    input wire rst,
//来自控制模块的信息
	input wire[5:0]							 stall,	

    //来自执行阶段的信息
    input wire[`RegAddrBus] ex_wd,
    input  wire ex_wreg,
    input  wire[`RegBus] ex_wdata,
    //为实现加载，存储指令而添加的输入接口
    input wire[`AluOpBus] ex_aluop,
    input wire[`RegBus] ex_mem_addr,
    input wire[`RegBus] ex_reg2,
    //高位低位寄存器
    input wire[`RegBus]           ex_hi,
	input wire[`RegBus]           ex_lo,
	input wire                    ex_whilo, 	




    //为实现加载，存储指令而添加的输出接口
    output reg[`AluOpBus] mem_aluop,
    output reg[`RegBus] mem_mem_addr,
    output reg[`RegBus] mem_reg2,
    //送到访存阶段的信息
    output reg [`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_wdata,


    //高位低位寄存器
    output reg[`RegBus]          mem_hi,
	output reg[`RegBus]          mem_lo,
	output reg                   mem_whilo	
    );

    always @(posedge clk) begin
        if (rst==`RstEnable) begin
            mem_wd = `NOPRegAddr;
            mem_wreg = `WriteDisable;
            mem_wdata = `ZeroWord;
            mem_aluop <= `NOP_OP;
            mem_mem_addr <= `ZeroWord;
            mem_reg2 <= `ZeroWord;

            mem_hi <= `ZeroWord;
		    mem_lo <= `ZeroWord;
		    mem_whilo <= `WriteDisable;	
        end else if(stall[3] == `Stop && stall[4] == `NoStop) begin
            mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
		    mem_wdata <= `ZeroWord;
  		    mem_aluop <= `NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;

            mem_hi <= `ZeroWord;
		    mem_lo <= `ZeroWord;
		    mem_whilo <= `WriteDisable;	
        end else if(stall[3] == `NoStop)begin
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            mem_aluop <= ex_aluop;
            mem_mem_addr <= ex_mem_addr;
            mem_reg2 <= ex_reg2;

            mem_hi <= ex_hi;
			mem_lo <= ex_lo;
			mem_whilo <= ex_whilo;
        end
    end
endmodule
