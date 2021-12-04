`timescale 1ns / 1ps
`include "defines.v"
module pipeline_cpu(
           input wire clk,
           input wire rst,
           input wire[`RegBus] rom_data_i,
           output wire[`RegBus] rom_addr_o,
           output wire rom_ce_o,
           //新增家口，连接数据存储器的RAM
           input wire [`RegBus] ram_data_i,
           output wire [`RegBus] ram_addr_o,
           output wire [`RegBus] ram_data_o,
           output wire [3:0] ram_we_o,
           output wire ram_ce_o 
       );


pc pc_reg0(
       .clk(clk),
       .rst(rst),
       .pc(rom_addr_o),
       .ce(rom_ce_o)
   );


//连接IF/ID和ID模块
wire [`InstBus] id_inst_i;



//连接id和id/ex模块
wire[`AluOpBus] id_aluop_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire[`RegAddrBus] id_wd_o;
wire id_wreg_o;
wire[`RegBus] id_inst_o;


//连接id/ex模块和ex模块
wire[`AluOpBus] ex_aluop_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire[`RegAddrBus] ex_wd_i;
wire ex_wreg_i;
wire[`RegBus] ex_inst_i;

//连接ex模块和ex/mem模块
wire[`RegBus] ex_wdata_o;
wire[`RegAddrBus] ex_wd_o;
wire ex_wreg_o;
//lw和sw需求
wire[`AluOpBus] ex_aluop_o;
wire[`RegBus] ex_mem_addr_o;
wire[`RegBus] ex_reg2_o;


//连接ex/mem模块和mem模块
wire[`RegBus] mem_wdata_i;
wire[`RegAddrBus] mem_wd_i;
wire mem_wreg_i;
//lw和sw的需求
wire[`AluOpBus] mem_aluop_i;
wire[`RegBus] mem_mem_addr_i;
wire[`RegBus] mem_reg2_i;

//连接mem模块和mem/wb模块
wire[`RegBus] mem_wdata_o;
wire[`RegAddrBus] mem_wd_o;
wire mem_wreg_o;


//连接mem/wb模块和regfile模块
wire[`RegBus] wb_wdata_i;
wire[`RegAddrBus] wb_wd_i;
wire wb_wreg_i;

//连接译码阶段的Id模块和通用寄存器Regfile模块
wire reg1_read;
wire reg2_read;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;


if_id if_id0(
          .rst(rst),
          .clk(clk),
          .if_inst(rom_data_i),
          .id_inst(id_inst_i)
      );

id id0(
       .rst(rst),
       //处于访存阶段的指令要写入目的寄存器信息
    //    .mem_wreg_i(mem_wreg_o),
    //    .mem_wdata_i(mem_wdata_o),
    //    .mem_wd_i(mem_wd_o),

       .inst_i(id_inst_i),
       .aluop_o(id_aluop_o),
       .reg1_o(id_reg1_o),
       .reg2_o(id_reg2_o),
       .wd_o(id_wd_o),
       .wreg_o(id_wreg_o),
       .inst_o(id_inst_o),
       //送到regfile的信息
       .reg1_read_o(reg1_read),
       .reg2_read_o(reg2_read),
       .reg1_addr_o(reg1_addr),
       .reg2_addr_o(reg2_addr),
       .reg1_data_i(reg1_data),
       .reg2_data_i(reg2_data)
   );

id_ex id_ex0(
          .rst(rst),
          .clk(clk),
          //从译码阶段ID模块传递的信息
          .id_aluop(id_aluop_o),
          .id_reg1(id_reg1_o),
          .id_reg2(id_reg2_o),
          .id_wd(id_wd_o),
          .id_wreg(id_wreg_o),
          .id_inst(id_inst_o),
          //传递到执行阶段EX模块的信息
          .ex_aluop(ex_aluop_i),
          .ex_reg1(ex_reg1_i),
          .ex_reg2(ex_reg2_i),
          .ex_wd(ex_wd_i),
          .ex_wreg(ex_wreg_i),
          .ex_inst(ex_inst_i)
      );

ex ex0(
       .rst(rst),
       //送到执行阶段EX模块的信息
       .alu_control(ex_aluop_i),
       .alu_src1(ex_reg1_i),
       .alu_src2(ex_reg2_i),
       .wd_i(ex_wd_i),
       .wreg_i(ex_wreg_i),
       .inst_i(ex_inst_i),
       //EX模块的输出送到EX/MEM模块
       .alu_result(ex_wdata_o),
       .wd_o(ex_wd_o),
       .wreg_o(ex_wreg_o),

        //lw和sw
       .aluop_o(ex_aluop_o),
	   .mem_addr_o(ex_mem_addr_o),
	   .reg2_o(ex_reg2_o)
   );

ex_mem ex_mem0(
    .rst(rst),
    .clk(clk),

    //来自执行阶段的EX模块的信息
    .ex_wdata(ex_wdata_o),
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),


    .ex_aluop(ex_aluop_o),
	.ex_mem_addr(ex_mem_addr_o),
	.ex_reg2(ex_reg2_o),


    //送到mem模块的信息
    .mem_wdata(mem_wdata_i),
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),


    .mem_aluop(mem_aluop_i),
	.mem_mem_addr(mem_mem_addr_i),
	.mem_reg2(mem_reg2_i)
);

mem mem0(
    .rst(rst),



    .wdata_i(mem_wdata_i),
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),

    .aluop_i(mem_aluop_i),
	.mem_addr_i(mem_mem_addr_i),
	.reg2_i(mem_reg2_i),



    //送到mem/wb模块的数据
    .wdata_o(mem_wdata_o),
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    //送到memory模块的信息
    .mem_addr_o(ram_addr_o),
    .mem_we_o(ram_we_o),
    .mem_data_o(ram_data_o),
    .mem_ce_o(ram_ce_o),


    //来自ram的信息
    .mem_data_i(ram_data_i)
);

mem_wb mem_wb0(
    .rst(rst),
    .clk(clk),
    .mem_wdata(mem_wdata_o),
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .wb_wdata(wb_wdata_i),
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i)
);

regfile regfile0(
    .clk(clk),
    .rst(rst),
    .re1(reg1_read),
    .raddr1(reg1_addr),
    .re2(reg2_read),
    .raddr2(reg2_addr),
    .we(wb_wreg_i),
    .waddr(wb_wd_i),
    .wdata(wb_wdata_i),
    .rdata1(reg1_data),
    .rdata2(reg2_data)
);

endmodule
