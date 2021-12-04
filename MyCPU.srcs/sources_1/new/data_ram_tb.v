`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/11/02 08:39:39
// Design Name:
// Module Name: data_ram_tb
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


module data_ram_tb();
reg clk;
reg ce;
reg we;
reg[31:0] addr;
reg[3:0] sel;
reg[31:0] data_i;
wire[31:0] data_o;
data_ram data_ram1(.clk(clk),.ce(ce),.we(we),.addr(addr),.sel(sel),.data_i(data_i),.data_o(data_o));

integer i,j,k;
initial
    clk=1;
always #10 clk=~clk;

initial begin
    ce =0;
    we=0;
    sel=4'b0001;
    data_i=32'hfedcba98;
    addr=0;
    #100 ce=1;
    we =1;
    for(j=0;j<10;j=j+1) begin
        sel=4'b0001;
        for(i=0;i<4;i=i+1) begin
            #40
            addr=addr+1;
            sel=sel<<1;
            data_i=data_i-32'h01010101;
        end
    end
    #40;
    we=0;
    for(k=0;k<40;k=k+1) begin
        addr =k;
        #20;
    end
end

endmodule
