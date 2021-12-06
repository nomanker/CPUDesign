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
           output wire  ram_we_o,
           output wire ram_ce_o 
       );



//连接IF/ID和ID模块
wire[`InstAddrBus] id_pc_i;
wire [`InstBus] id_inst_i;



//连接id和id/ex模块
wire[`AluOpBus] id_aluop_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire[`RegAddrBus] id_wd_o;
wire id_wreg_o;
wire[`RegBus] id_inst_o;
wire id_is_in_delayslot_o;
wire[`RegBus] id_link_address_o;


//连接id/ex模块和ex模块
wire[`AluOpBus] ex_aluop_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire[`RegAddrBus] ex_wd_i;
wire ex_wreg_i;
wire[`RegBus] ex_inst_i;
wire ex_is_in_delayslot_i;	
wire[`RegBus] ex_link_address_i;

//连接ex模块和ex/mem模块
wire[`RegBus] ex_wdata_o;
wire[`RegAddrBus] ex_wd_o;
wire ex_wreg_o;
wire[`RegBus] ex_hi_o;
wire[`RegBus] ex_lo_o;
wire ex_whilo_o;

//lw和sw需求
wire[`AluOpBus] ex_aluop_o;
wire[`RegBus] ex_mem_addr_o;
wire[`RegBus] ex_reg2_o;


//连接ex/mem模块和mem模块
wire[`RegBus] mem_wdata_i;
wire[`RegAddrBus] mem_wd_i;
wire mem_wreg_i;
wire[`RegBus] mem_hi_i;
wire[`RegBus] mem_lo_i;
wire mem_whilo_i;

//lw和sw的需求
wire[`AluOpBus] mem_aluop_i;
wire[`RegBus] mem_mem_addr_i;
wire[`RegBus] mem_reg2_i;

//连接mem模块和mem/wb模块
wire[`RegBus] mem_wdata_o;
wire[`RegAddrBus] mem_wd_o;
wire mem_wreg_o;

wire[`RegBus] mem_hi_o;
wire[`RegBus] mem_lo_o;
wire mem_whilo_o;

//连接mem/wb模块和regfile模块
wire[`RegBus] wb_wdata_i;
wire[`RegAddrBus] wb_wd_i;
wire wb_wreg_i;

wire[`RegBus] wb_hi_i;
wire[`RegBus] wb_lo_i;
wire wb_whilo_i;
//连接译码阶段的Id模块和通用寄存器Regfile模块
wire reg1_read;
wire reg2_read;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;

//连接执行阶段与hilo模块的输出，读取HI、LO寄存器
wire[`RegBus] 	hi;
wire[`RegBus]   lo;

//跳转指令的需求
wire is_in_delayslot_i;
wire is_in_delayslot_o;
wire next_inst_in_delayslot_o;
wire id_branch_flag_o;
wire[`RegBus] branch_target_address;

pc pc_reg0(
       .clk(clk),
       .rst(rst),
       .branch_flag_i(id_branch_flag_o),
	   .branch_target_address_i(branch_target_address),
       .pc(rom_addr_o),
       .ce(rom_ce_o)
);


if_id if_id0(
          .rst(rst),
          .clk(clk),
          .if_inst(rom_data_i),
          .id_inst(id_inst_i),
          .if_pc(rom_addr_o),
          .id_pc(id_pc_i)
      );

id id0(
       .rst(rst),
       //处于访存阶段的指令要写入目的寄存器信息
    //    .mem_wreg_i(mem_wreg_o),
    //    .mem_wdata_i(mem_wdata_o),
    //    .mem_wd_i(mem_wd_o),

       .pc_i(id_pc_i),
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
       .reg2_data_i(reg2_data),
       //延迟槽
       .is_in_delayslot_i(is_in_delayslot_i),

       .next_inst_in_delayslot_o(next_inst_in_delayslot_o),	
	   .branch_flag_o(id_branch_flag_o),
	   .branch_target_address_o(branch_target_address),       
	   .link_addr_o(id_link_address_o),
	   .is_in_delayslot_o(id_is_in_delayslot_o),



       //处于执行阶段的指令要写入的目的寄存器信息
		.ex_wreg_i(ex_wreg_o),
		.ex_wdata_i(ex_wdata_o),
		.ex_wd_i(ex_wd_o),

        //处于访存阶段的指令要写入的目的寄存器信息
		.mem_wreg_i(mem_wreg_o),
		.mem_wdata_i(mem_wdata_o),
		.mem_wd_i(mem_wd_o)

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
          .id_link_address(id_link_address_o),
		  .id_is_in_delayslot(id_is_in_delayslot_o),
		  .next_inst_in_delayslot_i(next_inst_in_delayslot_o),		
          //传递到执行阶段EX模块的信息
          .ex_aluop(ex_aluop_i),
          .ex_reg1(ex_reg1_i),
          .ex_reg2(ex_reg2_i),
          .ex_wd(ex_wd_i),
          .ex_wreg(ex_wreg_i),
          .ex_inst(ex_inst_i),
          .ex_link_address(ex_link_address_i),
  	      .ex_is_in_delayslot(ex_is_in_delayslot_i),
		  .is_in_delayslot_o(is_in_delayslot_i)	
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
		.hi_i(hi),
		.lo_i(lo),

	   .wb_hi_i(wb_hi_i),
	   .wb_lo_i(wb_lo_i),
	   .wb_whilo_i(wb_whilo_i),
	   .mem_hi_i(mem_hi_o),
	   .mem_lo_i(mem_lo_o),
	   .mem_whilo_i(mem_whilo_o),
       //EX模块的输出送到EX/MEM模块
       .alu_result(ex_wdata_o),
       .wd_o(ex_wd_o),
       .wreg_o(ex_wreg_o),
       .hi_o(ex_hi_o),
	   .lo_o(ex_lo_o),
	   .whilo_o(ex_whilo_o),
		

        //lw和sw
       .aluop_o(ex_aluop_o),
	   .mem_addr_o(ex_mem_addr_o),
	   .reg2_o(ex_reg2_o),
       .link_address_i(ex_link_address_i),
	   .is_in_delayslot_i(ex_is_in_delayslot_i)
   );

ex_mem ex_mem0(
    .rst(rst),
    .clk(clk),

    //来自执行阶段的EX模块的信息
    .ex_wdata(ex_wdata_o),
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_hi(ex_hi_o),
	.ex_lo(ex_lo_o),
	.ex_whilo(ex_whilo_o),


    .ex_aluop(ex_aluop_o),
	.ex_mem_addr(ex_mem_addr_o),
	.ex_reg2(ex_reg2_o),


    //送到mem模块的信息
    .mem_wdata(mem_wdata_i),
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_hi(mem_hi_i),
	.mem_lo(mem_lo_i),
	.mem_whilo(mem_whilo_i),	


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
    
    .hi_i(mem_hi_i),
	.lo_i(mem_lo_i),
	.whilo_i(mem_whilo_i),	



    //送到mem/wb模块的数据
    .wdata_o(mem_wdata_o),
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .hi_o(mem_hi_o),
	.lo_o(mem_lo_o),
	.whilo_o(mem_whilo_o),

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
    .mem_hi(mem_hi_o),
	.mem_lo(mem_lo_o),
	.mem_whilo(mem_whilo_o),
    .wb_wdata(wb_wdata_i),
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_hi(wb_hi_i),
	.wb_lo(wb_lo_i),
	.wb_whilo(wb_whilo_i)	
);

hilo_reg hilo_reg0(
		.clk(clk),
		.rst(rst),
	
		//写端口
		.we(wb_whilo_i),
		.hi_i(wb_hi_i),
		.lo_i(wb_lo_i),
	
		//读端口1
		.hi_o(hi),
		.lo_o(lo)	
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
