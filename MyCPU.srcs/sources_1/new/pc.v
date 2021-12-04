`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/10/26 08:25:33
// Design Name:
// Module Name: pc
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


module pc(
           input wire rst,
           input wire clk,
           output reg ce,
           output reg[31:0] pc
       );

always @(posedge clk) begin
    if(rst==1) begin
        ce<=0;
    end
    else begin
        ce<=1;
    end
end

always @(posedge clk) begin
    if(ce==0) begin
        pc<=32'h0;
    end
    else begin
        pc<=pc+32'h4;
    end
end
endmodule
