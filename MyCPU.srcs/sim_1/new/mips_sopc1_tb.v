`timescale 1ns / 1ps
module mips_sopc1_tb(
    );
    reg clk;
    reg rst;
    initial begin
        clk=1'b0;
        forever #10 clk=~clk;
    end

    initial begin
        rst=1;
        #100 rst =0;
       #1000 $stop;
    end
    mips_sopc1 mips_sopc10(.clk(clk),.rst(rst));
endmodule
