`timescale 1ns/1ps

module regfile(
           input wire rst,
           input wire clk,
           input wire[4:0] waddr,
           input wire[31:0] wdata,
           input wire we,
           input wire [4:0] raddr1,
           input wire re1,
           output reg[31:0] rdata1,
           input wire[4:0] raddr2,
           input wire re2,
           output reg[31:0] rdata2
       );
/*第一个数组代表的是位数，第二个数组代表的是一维数组0-31*/
reg[31:0] regs[0:31];

// integer i;
// initial begin
//     // regs[0]=32'h0000_0000;
//     regs[1]=32'h0000_0001;
//     for (i=2; i<32; i=i+1) begin
//         regs[i]=regs[i-1]+32'h0000_0001;
//     end
// end
/*写信号处理*/
always @(posedge clk) begin
    if (rst==1'b0) begin
        if ((we==1'b1)&&(waddr!=5'b0)) begin
            regs[waddr]<=wdata;
        end
    end
end

/*第一个读信号处理*/
always@(*) begin
    if (rst==1) begin
        rdata1<=32'h0;
    end
    else if ((raddr1==5'b0)&&(re1==1'b1)) begin
        rdata1<=32'h0;
    end
    else if ((raddr1==waddr)&&(we==1'b1)&&(re1==1'b1)) begin
        rdata1<=wdata;
    end
    else if(re1==1'b1) begin
        rdata1<=regs[raddr1];
    end
    else begin
        rdata1<=32'h0;
    end
end

/*第二个读信号处理*/
always@(*) begin
    if (rst==1) begin
        rdata2<=32'h0;
    end
    else if ((raddr2==5'b0)&&(re2==1'b1)) begin
        rdata2<=32'h0;
    end
    else if ((raddr2==waddr)&&(we==1'b1)&&(re2==1'b1)) begin
        rdata2<=wdata;
    end
    else if(re2==1'b1) begin
        rdata2<=regs[raddr2];
    end
    else begin
        rdata2<=32'h0;
    end
end
endmodule
