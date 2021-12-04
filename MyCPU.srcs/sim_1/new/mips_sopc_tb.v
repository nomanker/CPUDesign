`timescale 1ns / 1ps
module mips_sopc_tb();
reg clk;
reg rst;
initial begin
    clk=1'b0;
    forever begin
        #10 clk=~clk;
    end
end


initial begin
    rst =1;
    #100 rst =0;
    #1000 $stop;
end

mips_sopc mips_sopc0(.clk(clk),.rst(rst));
endmodule
