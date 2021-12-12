// `timescale 1ns / 1ps

// //除法模块


`include "defines.v"
module mult(

           input	wire	clk,
           input wire	rst,

           input wire                    signed_mult_i,
           input wire[31:0]              opdata1_i,
           input wire[31:0]		   		 opdata2_i,
           input wire                    start_i,

           output reg[63:0]             result_o,
           output reg			             ready_o
       );

reg[5:0] cnt;
reg[64:0] multEnd;
reg[1:0] state;
reg[32:0] temp_op1;
reg[31:0] temp_op2;
reg[33:0] A;
reg[33:0] X;
reg[33:0] Q;

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        state <= `MultFree;
        ready_o <= `MultResultNotReady;
        result_o <= {`ZeroWord,`ZeroWord};
    end
    else begin
        case (state)
            `MultFree:	begin               //DivFree状态
                if(start_i == `MultStart) begin
                        state <= `MultOn;
                        cnt <= 6'b000000;
                        A <= {`ZeroWord,2'b00};
                        Q[0] <=0;
                        // if(signed_mult_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin
                        //     temp_op1 = ~opdata1_i + 1;
                        // end
                        // else begin
                            temp_op1 = opdata1_i;
                        // end
                        // if(signed_mult_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin
                        //     temp_op2 = ~opdata2_i + 1;
                        // end
                        // else begin
                            temp_op2 = opdata2_i;
                        // end
                        if(signed_mult_i==1'b0) begin
                            X <= {1'b0,1'b0,temp_op1}; 
                            Q <= {1'b0,temp_op2, 1'b0};
                        end else begin
                            X <= {temp_op1[31],temp_op1[31],temp_op1};
                            Q <= {temp_op2[31],temp_op2, 1'b0};
                        end
                        A <= {2'b00,`ZeroWord};
                end
                else begin
                    ready_o <= `MultResultNotReady;
                    result_o <= {`ZeroWord,`ZeroWord};
                end
            end
            `MultOn:	begin 
                    if(cnt != 6'b100000) begin
                        if({Q[1],Q[0]}==2'b00) begin
                            //Q和A同时右移一位
                            Q<={A[0],Q[33:1]};
                            A<={A[33],A[33:1]};
                        end else if({Q[1],Q[0]}==2'b01) begin
                            A = A+X;
                            //Q和A同时右移一位
                            Q<={A[0],Q[33:1]};
                            A<={A[33],A[33:1]};
                        end else if({Q[1],Q[0]}==2'b10) begin
                            A = A-X;
                            //Q和A同时右移一位
                            Q<={A[0],Q[33:1]};
                            A<={A[33],A[33:1]};
                        end else begin
                            //Q和A同时右移一位
                            Q<={A[0],Q[33:1]};
                            A<={A[33],A[33:1]};
                        end
                        cnt <= cnt + 1;
                    end
                    else begin
                        if({Q[1],Q[0]}==2'b01) begin
                            A = A+X;
                            //Q和A同时右移一位
                            Q<={A[0],Q[33:1]};
                            A<={A[33],A[33:1]};
                        end else if({Q[1],Q[0]}==2'b10) begin
                            A = A-X;
                            //Q和A同时右移一位
                            Q<={A[0],Q[33:1]};
                            A<={A[33],A[33:1]};
                        end
                        multEnd <= {A[31:0],Q[33:2]};
                        state <= `MultEnd;
                        cnt <= 6'b000000;
                    end
            end
            `MultEnd:			begin               //DivEnd状态
                
                result_o <= multEnd;
                ready_o <= `DivResultReady;
                if(start_i == `DivStop) begin
                    state <= `DivFree;
                    ready_o <= `DivResultNotReady;
                    result_o <= {`ZeroWord,`ZeroWord};
                end
            end
        endcase
    end
end

endmodule
