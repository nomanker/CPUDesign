`timescale 1ns / 1ps
`include "defines.v"
module ex(
           input wire rst,
           //发送到流线线暂停的请求模块
           output reg										stallreq ,

           input [`AluOpBus] alu_control,
           input [`RegBus] alu_src1,
           input [`RegBus] alu_src2,
           //新增输入接口inst_i,他的值就是当前处于执行阶段的指令
           input wire[`RegBus]    inst_i,

           //是否转移、以及link address
           input wire[`RegBus]           link_address_i,
           input wire                    is_in_delayslot_i,


           //新增来自除法模块的输入
           input  wire[`DoubleRegBus] div_result_i,
           input wire   div_ready_i, 

           //来自乘法的输入
           input wire[`DoubleRegBus] mult_result_i,
           input wire mult_ready_i,

           output reg[`RegBus] alu_result,
           output reg[`RegAddrBus] wd_o,
           output reg wreg_o,
           input  wire wreg_i,
           input wire[`RegAddrBus] wd_i,

           //下面新增的几个输出接口时为了加载，存储指令准备的
           output wire[`AluOpBus] aluop_o,
           output wire[`RegBus]  mem_addr_o,
           output wire[`RegBus]  reg2_o,

           //增加高位寄存器和低位寄存器
           //HI、LO寄存器的值
           input wire[`RegBus]           hi_i,
           input wire[`RegBus]           lo_i,

           //回写阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
           input wire[`RegBus]           wb_hi_i,
           input wire[`RegBus]           wb_lo_i,
           input wire                    wb_whilo_i,

           //访存阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
           input wire[`RegBus]           mem_hi_i,
           input wire[`RegBus]           mem_lo_i,
           input wire                    mem_whilo_i,

           output reg[`RegBus]           hi_o,
           output reg[`RegBus]           lo_o,
           output reg                    whilo_o,

           //新增到除法输出魔魁啊的输出
           output reg[`RegBus] div_opdata1_o,
           output reg[`RegBus] div_opdata2_o,
           output reg div_start_o,
           output reg signed_div_o,

           //新增乘法模块的输入输出
            output reg[`RegBus] mult_opdata1_o,
            output reg[`RegBus] mult_opdata2_o,
            output reg mult_start_o,
            output reg signed_mult_o

       );
wire[`RegBus] alu_src2_mux;
wire[`RegBus] result_sum;//保存加法的结果
wire src1_lt_src2;
wire[`RegBus] reg1_i_not;//保存第一个操作数reg2_i的补码
wire[`RegBus] opdata1_mult;    //乘法操作中被乘数
wire[`RegBus] opdata2_mult;    //乘法操作中的乘数
wire[`DoubleRegBus] hilo_temp;   //临时保存乘法的结果，宽度为64位
reg[`DoubleRegBus] mulres;      //保存乘法的结果，宽度为64位

//移动操作的结果
reg[`RegBus] moveres;
reg[`RegBus] HI;
reg[`RegBus] LO;


//是否有用除法运算导致流水线暂停
reg stallreq_for_div;
reg stallreq_for_mult;


assign alu_src2_mux = ((alu_control==`SUB_OP)||(alu_control==`SLT_OP)||(alu_control==`SUBU_OP))?(~alu_src2)+1:alu_src2;
assign result_sum = alu_src1+alu_src2_mux;
assign src1_lt_src2=(alu_control==`SLT_OP)?((alu_src1[31]&&!alu_src2[31])
        ||!alu_src1[31]&&!alu_src2[31]&&result_sum[31]
        ||alu_src1[31]&&alu_src2[31]&&result_sum[31])
       :(alu_src1<alu_src2);
//对操作数1每位取反，赋值给reg1_i_not
assign reg1_i_not = ~alu_src1;

/*****************************乘法运算******************************
******************************************************************
**************************************************/
//取得乘法运算的被乘数，如果是有符号乘法，且被乘数是负数的话，那么取反加1
assign opdata1_mult = ((alu_control == `MULT_OP)&& (alu_src1[31] == 1'b1)) ? (~alu_src1 + 1) : alu_src1;
assign opdata2_mult = ((alu_control == `MULT_OP)&& (alu_src2[31] == 1'b1)) ? (~alu_src2 + 1) : alu_src2;
assign hilo_temp = opdata1_mult * opdata2_mult;
always @ (*) begin
    if(rst == `RstEnable) begin
        mulres <= {`ZeroWord,`ZeroWord};
    end
    else if ((alu_control == `MULT_OP)) begin
        if(alu_src1[31] ^ alu_src2[31] == 1'b1) begin
            mulres <= ~hilo_temp + 1;
        end
        else begin
            mulres <= hilo_temp;
        end
    end
    else begin
        mulres <= hilo_temp;
    end
end
//得到最新的HI、LO寄存器的值，此处要解决指令数据相关问题
always @ (*) begin
    if(rst == `RstEnable) begin
        {HI,LO} <= {`ZeroWord,`ZeroWord};
    end
    else if(mem_whilo_i == `WriteEnable) begin
        {HI,LO} <= {mem_hi_i,mem_lo_i};
    end
    else if(wb_whilo_i == `WriteEnable) begin
        {HI,LO} <= {wb_hi_i,wb_lo_i};
    end
    else begin
        {HI,LO} <= {hi_i,lo_i};
    end
end
//alupo_o回传递到访存阶段，届时将利用其确定加载，存储类型
assign aluop_o = alu_control;
//mem_addr_o 会传递到访存阶段，时加载，存储指令对应的存储器地址，此处的alu_src1就是加载，存储指令中地址为base的通用寄存器的值，inst_i[15:0]就是指令中
//的offset，通过mem_addr_o的计算
assign mem_addr_o = alu_src1 +{{16{inst_i[15]}},inst_i[15:0]};
//reg2_i 是存储指令要存储的数据
//将该值通过
assign reg2_o = alu_src2;

/*****************************************数据移动指令*******************
***********************************************************************
**********************************************************************/

always @(*) begin
    if(rst==`RstEnable) begin
        alu_result=`ZeroWord;
        wd_o = `NOPRegAddr;
        wreg_o= `WriteDisable;
        whilo_o <=`WriteDisable;
        hi_o <= `ZeroWord;
		lo_o <= `ZeroWord;
    end
    else begin
        wd_o=wd_i;
        wreg_o=wreg_i;	
        case(alu_control)
            `ADD_OP,`SUB_OP,`ADDU_OP,`SUBU_OP,`ADDIU_OP,`ADDI_OP: begin
                alu_result<=result_sum;
            end
            `SLT_OP,`SLTU_OP: begin
                alu_result<=src1_lt_src2;
            end
            `AND_OP: begin
                alu_result<=alu_src1&alu_src2;
            end
            `NOR_OP: begin
                alu_result<=~(alu_src1|alu_src2);
            end
            `OR_OP: begin
                alu_result<=(alu_src1|alu_src2);
            end
            `XOR_OP: begin
                alu_result<=alu_src1^alu_src2;
            end
            `SLL_OP: begin
                alu_result<=alu_src2<<alu_src1[4:0];
            end
            `SRL_OP: begin
                alu_result<=alu_src2>>alu_src1[4:0];
            end
            `SRA_OP: begin
                alu_result<=({32{alu_src2[31]}}<<(6'd32-{1'b0,alu_src1[4:0]}))
                |alu_src2>>alu_src1[4:0];
            end
            `LUI_OP: begin
                alu_result<={alu_src2[15:0],16'd0};
            end
            `JAL_OP: begin
                alu_result <= link_address_i;
            end
            `MULT_OP,`MULTU_OP:begin
                whilo_o <= `WriteEnable;
                hi_o <= mult_result_i[63:32];
			    lo_o <= mult_result_i[31:0];	
            end
            `MFHI_OP: begin
                alu_result <= HI;
            end
            `MFLO_OP: begin
                alu_result <=LO;
            end
            `MTHI_OP:begin
                whilo_o <=`WriteEnable;
                hi_o <= alu_src1;
		        lo_o <= LO;
            end
            `MTLO_OP: begin
                whilo_o <=`WriteEnable;
                hi_o <= HI;
		        lo_o <= alu_src1;
            end
            `DIVU_OP,`DIV_OP:begin
                whilo_o <= `WriteEnable;
			    hi_o <= div_result_i[63:32];
			    lo_o <= div_result_i[31:0];
            end
            default: begin
                alu_result<=`ZeroWord;
                whilo_o <=`WriteDisable;
                hi_o <= `ZeroWord;
		        lo_o <= `ZeroWord;
            end
        endcase
    end
end


//暂停流水线
always @(*) begin
    stallreq=stallreq_for_div|stallreq_for_mult;
end

//DIV、DIVU指令	
	always @ (*) begin
		if(rst == `RstEnable) begin
			stallreq_for_div <= `NoStop;
	        div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
		end else begin
			stallreq_for_div <= `NoStop;
	        div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;	
			case (alu_control) 
				`DIV_OP:		begin
					if(div_ready_i == `DivResultNotReady) begin
	    			div_opdata1_o <= alu_src1;
						div_opdata2_o <= alu_src2;
						div_start_o <= `DivStart;
						signed_div_o <= 1'b1;
						stallreq_for_div <= `Stop;
					end else if(div_ready_i == `DivResultReady) begin
	    			div_opdata1_o <= alu_src1;
						div_opdata2_o <= alu_src2;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b1;
						stallreq_for_div <= `NoStop;
					end else begin						
	    			div_opdata1_o <= `ZeroWord;
						div_opdata2_o <= `ZeroWord;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NoStop;
					end					
				end
				`DIVU_OP:		begin
					if(div_ready_i == `DivResultNotReady) begin
	    			div_opdata1_o <= alu_src1;
						div_opdata2_o <= alu_src2;
						div_start_o <= `DivStart;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `Stop;
					end else if(div_ready_i == `DivResultReady) begin
	    			div_opdata1_o <= alu_src1;
						div_opdata2_o <= alu_src2;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NoStop;
					end else begin						
	    			div_opdata1_o <= `ZeroWord;
						div_opdata2_o <= `ZeroWord;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NoStop;
					end					
				end
				default: begin
				end
			endcase
		end
	end	

//DIV、DIVU指令	
	always @ (*) begin
		if(rst == `RstEnable) begin
			stallreq_for_mult <= `NoStop;
	        mult_opdata1_o <= `ZeroWord;
			mult_opdata2_o <= `ZeroWord;
			mult_start_o <= `MultStop;
			signed_mult_o <= 1'b0;
		end else begin
			stallreq_for_mult <= `NoStop;
	        mult_opdata1_o <= `ZeroWord;
			mult_opdata2_o <= `ZeroWord;
			mult_start_o <= `DivStop;
			signed_mult_o <= 1'b0;	
			case (alu_control) 
				`MULT_OP:		begin
					if(mult_ready_i == `MultResultNotReady) begin
	    			    mult_opdata1_o <= alu_src1;
						mult_opdata2_o <= alu_src2;
						mult_start_o <= `MultStart;
						signed_mult_o <= 1'b1;
						stallreq_for_mult <= `Stop;
					end else if(mult_ready_i == `MultResultReady) begin
	    			    mult_opdata1_o <= alu_src1;
						mult_opdata2_o <= alu_src2;
						mult_start_o <= `MultStop;
						signed_mult_o <= 1'b1;
						stallreq_for_mult <= `NoStop;
					end else begin						
	    			    mult_opdata1_o <= `ZeroWord;
						mult_opdata2_o <= `ZeroWord;
						mult_start_o <= `MultStop;
						signed_mult_o <= 1'b0;
						stallreq_for_mult <= `NoStop;
					end					
				end
				`MULTU_OP:		begin
					if(mult_ready_i == `MultResultNotReady) begin
	    			    mult_opdata1_o <= alu_src1;
						mult_opdata2_o <= alu_src2;
						mult_start_o <= `MultStart;
						signed_mult_o <= 1'b0;
						stallreq_for_mult <= `Stop;
					end else if(mult_ready_i == `MultResultReady) begin
	    			    mult_opdata1_o <= alu_src1;
						mult_opdata2_o <= alu_src2;
						mult_start_o <= `MultStop;
						signed_mult_o <= 1'b0;
						stallreq_for_mult <= `NoStop;
					end else begin						
	    			    mult_opdata1_o <= `ZeroWord;
						mult_opdata2_o <= `ZeroWord;
						mult_start_o <= `MultStop;
						signed_mult_o <= 1'b0;
						stallreq_for_mult <= `NoStop;
					end					
				end
				default: begin
				end
			endcase
		end
	end
endmodule
