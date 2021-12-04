`timescale 1ns / 1ps
`include "defines.v"
module id_tb();
    reg rst;
    reg[`InstBus] inst_i;
    reg[`RegBus] reg1_data_i;
    reg[`RegBus] reg2_data_i;
    //送到regfile的信息
    wire reg1_read_o;
    wire reg2_read_o;
    wire[`RegAddrBus] reg1_addr_o;
    wire[`RegAddrBus] reg2_addr_o;
    //送到执行阶段的信息
    wire[`AluOpBus] aluop_o;
    wire[`RegBus] reg1_o;
    wire[`RegBus] reg2_o;
    wire[`RegAddrBus] wd_o;
    wire wreg_o;
    reg[`InstBus] inst_array[0:11];
    integer i;
    initial begin
        $readmemh("D:/inst_rom.data",inst_array);
    end
    id id0(.rst(rst),.inst_i(inst_i),
           .reg1_data_i(reg1_data_i),.reg2_data_i(reg2_data_i),
           .reg1_read_o(reg1_read_o),.reg2_read_o(reg2_read_o),
           .reg1_addr_o(reg1_addr_o),.reg2_addr_o(reg2_addr_o),
           .aluop_o(aluop_o),.reg1_o(reg1_o),.reg2_o(reg2_o),
           .wd_o(wd_o),.wreg_o(wreg_o)
           );//实例化
    initial begin
        rst=`RstEnable;
        #100
        rst=`RstDisable;
        reg1_data_i=32'h12345678;
        reg2_data_i=32'hfedcba98;
        for(i=0;i<12;i=i+1)begin
            inst_i=inst_array[i];
            #20;
        end
        #20 $stop;
    end
endmodule