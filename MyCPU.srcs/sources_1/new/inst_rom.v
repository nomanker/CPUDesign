`timescale 1ns / 1ps
module inst_rom(
           input wire ce,
           input wire[31:0] addr,
           output reg[31:0] inst
       );
reg[31:0] inst_mem[0:131071];
initial
    $readmemh("inst_rom.mem",inst_mem);
always @(*) begin
    if(ce==0) begin
        inst<=32'b0;
    end
    else begin
        inst<=inst_mem[addr[18:2]];
    end
end
endmodule
