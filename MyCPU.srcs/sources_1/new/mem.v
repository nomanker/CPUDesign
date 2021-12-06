`timescale 1ns / 1ps
`include "defines.v"
module mem(
           input  wire rst,
           //来自执行阶段的信息
           input wire [`RegAddrBus] wd_i,
           input wire wreg_i,
           input wire[`RegBus] wdata_i,

           input wire[`RegBus]           hi_i,
	       input wire[`RegBus]           lo_i,
	       input wire                    whilo_i,	
           
           //新增家口，来自执行阶段的信息
           input wire[`AluOpBus] aluop_i,
           input wire[`RegBus] mem_addr_i,
           input wire[`RegBus] reg2_i,
           //来自memory的信息
           input wire[`RegBus] mem_data_i,




           //送到memory的信息
           output reg[`RegBus] mem_addr_o,
           output wire mem_we_o,
           output reg[`RegBus] mem_data_o,
           output reg mem_ce_o,

           //送到回写阶段的信息
           output reg[`RegAddrBus] wd_o,
           output reg wreg_o,
           output reg[`RegBus] wdata_o,
           output reg[`RegBus]          hi_o,
	       output reg[`RegBus]          lo_o,
	       output reg                   whilo_o	
       );

wire [`RegBus] zero32;
reg mem_we;
assign mem_we_o = mem_we;
assign zero32 = `ZeroWord;


always @(*) begin
    if (rst==`RstEnable) begin
        wd_o<= `NOPRegAddr;
        wreg_o<= `WriteDisable;
        wdata_o<=`ZeroWord;

        //新增memory的信息
        mem_addr_o <= `ZeroWord;
        mem_we <= `WriteDisable;
        mem_data_o <= `ZeroWord;
        mem_ce_o <= `ChipDisable;

        hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;
		whilo_o <= `WriteDisable;
    end
    else begin
        wd_o<= wd_i;
        wreg_o<=wreg_i;
        wdata_o<=wdata_i;
        mem_we <= `WriteDisable;
        mem_addr_o <= `ZeroWord;
        mem_ce_o <= `ChipDisable;
        hi_o <= hi_i;
		lo_o <= lo_i;
		whilo_o <= whilo_i;	
    end

    case (aluop_i)
        `LW_OP: begin
            mem_addr_o <= mem_addr_i;
            mem_we <= `WriteDisable;
            wdata_o <= mem_data_i;
            mem_ce_o <= `ChipEnable;
        end
        `SW_OP: begin
            mem_addr_o <= mem_addr_i;
            mem_we <= `WriteEnable;
            mem_data_o <= reg2_i;
            mem_ce_o <= `ChipEnable;
        end
        default:	begin
            //什么也不做
        end
    endcase
end
endmodule
