`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/26 08:25:33
// Design Name:
// Module Name: inst_fetch
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module inst_fetch(
           input wire rst,
           input wire clk,
           output wire[31:0] inst_o
       );


wire [31:0] pc;
wire ce;
pc pc0(.clk(clk),.rst(rst),.pc(pc),.ce(ce));
inst_rom inst_rom0(.ce(ce),.addr(pc),.inst(inst_o));
endmodule
