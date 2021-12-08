`timescale 1ns / 1ps
`include "defines.v"
module if_id(
    input  wire clk,
    input wire rst,

    //来自取值阶段的信号
    // input  wire[`InstAddrBus] if_pc,
    input  wire[`InstBus] if_inst,

    //对应译码阶段的信号
    // output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst,

    //跳转指令需要拿到pc的的指令地址
    input wire[`InstAddrBus] if_pc,
    //跳转指令传到id的指令地址

    //来自控制模块的信息
	input wire[5:0]               stall,
    
    output reg[`InstAddrBus] id_pc
    );


    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            // id_pc <= `ZeroWord;
            id_inst <=`ZeroWord;
            id_pc <= `ZeroWord;
        end else if(stall[1] == `Stop && stall[2] == `NoStop) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
        end else if(stall[1] == `NoStop) begin 
            id_pc <=if_pc;
            id_inst <= if_inst;
            
        end
    end
    
endmodule
