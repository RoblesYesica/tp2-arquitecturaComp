`timescale 1ns / 1ps

module ALU#(
    parameter NB_OP   = 6,
    parameter NB_DATA = 8
   ) 
   (
    input wire [NB_OP-1 : 0] i_operation,
    input wire signed [NB_DATA-1:0] i_data_a,
    input wire signed [NB_DATA-1:0] i_data_b,
    output wire signed [NB_DATA-1:0] o_result
    );

  localparam ADD_OP = 6'b100000;
  localparam SUB_OP = 6'b100010;
  localparam AND_OP = 6'b100100;
  localparam OR_OP = 6'b100101;
  localparam XOR_OP = 6'b100110;
  localparam SRA_OP = 6'b000011;
  localparam SRL_OP = 6'b000010;
  localparam NOR_OP = 6'b100111;

  reg signed [NB_DATA-1:0] res;

  always @(*) begin : alu
    case (i_operation)
      ADD_OP:  res = i_data_a + i_data_b;
      SUB_OP:  res = i_data_a - i_data_b;
      AND_OP:  res = i_data_a & i_data_b;
      OR_OP:   res = i_data_a | i_data_b;
      XOR_OP:  res = i_data_a ^ i_data_b;
      SRA_OP:  res = i_data_a >>> i_data_b;  // 
      SRL_OP:  res = i_data_a >> i_data_b;  // 
      NOR_OP:  res = ~(i_data_a | i_data_b);
      default: res = 8'hff;
    endcase
  end

  assign o_result = res;

endmodule
