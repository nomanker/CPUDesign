`timescale 1ns / 1ps
module ex_tb();
    reg rst;
    reg[3:0] alu_control;
    reg[31:0] alu_src1;
    reg[31:0] alu_src2;
    wire[31:0] alu_result;
    
    integer i;
    
    ex ex1(.rst(rst),
            .alu_control(alu_control),
            .alu_src1(alu_src1),
            .alu_src2(alu_src2),
            .alu_result(alu_result)
    );
    
    initial begin
        alu_control=4'b0000;
        alu_src1=32'h0000_0001;
        alu_src2=32'h0000_0002;
        
        #20;
        for(i=0;i<12;i=i+1)begin 
            $monitor("aluSrc1=%h,aluControl=%b,aluSrc2=%h,aluResult=%h",
                            alu_src1,alu_control,alu_src2,alu_result);
            #20;
            alu_control=alu_control+1;
        end  
        #40 $finish;
    end
endmodule
