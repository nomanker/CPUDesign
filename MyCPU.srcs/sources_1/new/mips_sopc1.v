`timescale 1ns / 1ps
`include "defines.v"
module mips_sopc1(
    input  wire  clk,
    input wire rst
    );

    wire[`InstAddrBus] inst_addr;
    wire[`InstBus] inst;

    wire rom_ce;

    pipeline_cpu pipeline_cpu0(
        .rst(rst),
        .clk(clk),
        .rom_data_i(inst),
        .rom_ce_o(rom_ce),
        .rom_addr_o(inst_addr)
    );

    inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );
endmodule
