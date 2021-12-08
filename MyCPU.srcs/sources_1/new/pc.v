`timescale 1ns / 1ps
`include"defines.v"

module pc(
           input wire rst,
           input wire clk,
           output reg ce,
           output reg[31:0] pc,

           //来自译码阶段ID模块的信息
           input wire  branch_flag_i,
           input wire[`RegBus] branch_target_address_i,

           //流水线暂停机制
           input wire[5:0] stall
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
    if(ce==`ChipDisable) begin
        pc<=32'h0;
    end else if(stall[0] == `NoStop) begin
		if(branch_flag_i == `Branch) begin
				pc <= branch_target_address_i;
			end else begin
	  		    pc <= pc + 4'h4;
	  	end
	end
end
endmodule
