`timescale 1ns/1ps
// `include "regfile.v"
module regfile_tb ();
reg rst;
reg clk;
reg[4:0] waddr;
reg[31:0] wdata;
reg we;
reg[4:0] raddr1;
reg re1;
wire[31:0] rdata1;
reg[4:0] raddr2;
reg re2;
wire[31:0] rdata2;
integer i;

regfile regfile1(
            .rst(rst),
            .clk(clk),
            .waddr(waddr),
            .wdata(wdata),
            .we(we),
            .raddr1(raddr1),
            .re1(re1),
            .rdata1(rdata1),
            .raddr2(raddr2),
            .re2(re2),
            .rdata2(rdata2)
        );

initial begin
    $dumpfile("regfile_test.vcd");
    $dumpvars(0, regfile_tb);
    clk<=1;
    rst<=0;
    #50
     rst<=1;
    #50
     rst<=0;
    we<=1;
    for(i=0;i<32;i=i+1) begin
        waddr<=i;
        wdata<=i;
        #30;
    end
    we<=0;
    re1<=1;
    re2<=1;
    for(i=0;i<32;i=i+1) begin
        raddr1<=i;
        raddr2<=31-i;
        #30;
    end
    re1<=0;
    re2<=0;
    #30
     we<=1;
    waddr<=15;
    wdata<=32'h0af;
    re1<=1;
    raddr1<=15;
    #30
     $finish;
end
always #10 clk=~clk;
endmodule //regfile_tb
