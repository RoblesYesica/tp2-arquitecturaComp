`timescale 1ns / 1ps
module ALU #(
    parameter NB_DATA = 8,
    parameter NB_OP = 6
    )
   (
    input  wire [NB_DATA -1 : 0] i_dataA,
    input  wire [NB_DATA -1 : 0] i_dataB,
    input  wire [NB_OP -1 : 0]   i_op,
    output wire [NB_DATA-1 : 0]  o_result,
    output wire                  o_overflow
  );

    localparam ADD = 6'b100000;
    localparam SUB = 6'b100010;

    localparam AND = 6'b100100;
    localparam OR  = 6'b100101;
    localparam XOR = 6'b100110;
    localparam NOR = 6'b100111;
    
    localparam SRA = 6'b000011;
    localparam SRL = 6'b000010;
  
    wire [NB_DATA-1  : 0] tmpAddSub;
    wire                  tmpOverflow;
    reg [NB_DATA-1  : 0] tmpResult;
     
 
  ADD_SUB #(
            .NB_DATA(NB_DATA)
           )
  add_sub1(
          .i_dataA(i_dataA),
          .i_dataB(i_dataB),
          .ctrl(i_op[1]),
          .o_result(tmpAddSub),
          .o_overflow(tmpOverflow)
          );
 
  always  @(*)
    begin
      case(i_op)
        ADD: tmpResult = tmpAddSub;      //ADD    
        SUB: tmpResult = tmpAddSub;       //SUB 
    
        AND: tmpResult = i_dataA & i_dataB; //AND
        OR: tmpResult = i_dataA | i_dataB; //OR
        XOR: tmpResult = i_dataA ^ i_dataB; //XOR
        NOR: tmpResult = ~( i_dataA | i_dataB); //NOR

        SRA: tmpResult = i_dataA >>> i_dataB; //SRA
        SRL: tmpResult = i_dataA >> i_dataB; //SRL

        default : tmpResult = {NB_DATA {1'b1}};
       
 endcase
end

 assign o_result = tmpResult;
 assign o_overflow=(i_op==ADD |i_op==SUB) ? tmpOverflow : 0;

endmodule        

     
