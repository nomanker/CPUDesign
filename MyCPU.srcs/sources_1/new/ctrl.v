`timescale 1ns / 1ps
`include "defines.v"
module ctrl(
    input wire rst,
    input wire stallreq_from_id,//来自译码阶段的暂停请求,
    input wire stallreq_from_ex,
    output reg[5:0] stall
    );

    always @( *) begin
        if(rst == `RstEnable) begin
            stall <= 6'b000_000;
        end else if (stallreq_from_ex== `Stop) begin
            stall<= 6'b001111;//pc的值，取值，译码，执行暂停，访存，回写阶段继续
        end else if(stallreq_from_id==`Stop) begin
            stall<= 6'b000111;//pc的值，取值，译码暂停，其他的继续
        end else begin
            stall<= 6'b000000;
        end
    end
endmodule
