`timescale 1ns / 1ps
module ALU_TB; 
    parameter  NB_DATA = 8;
    parameter  NB_OP = 6;
    parameter N_TEST = 4;
    
    reg [NB_DATA -1 : 0] i_dataA;
    reg [NB_DATA -1 : 0] i_dataB;
    reg [NB_OP -1 : 0]   i_op;
    wire [NB_DATA-1 : 0] o_result;
    wire                 o_overflow;
    
    integer op_cont;
    integer tests_cont;

    localparam ADD = 6'b100000;
    localparam SUB = 6'b100010;
    localparam AND = 6'b100100;
    localparam OR  = 6'b100101;
    localparam XOR = 6'b100110;
    localparam NOR = 6'b100111;
    localparam SRA = 6'b000011;
    localparam SRL = 6'b000010;
  
    reg [NB_OP-1:0] operation [7:0];
 

    ALU #(
        .NB_DATA(NB_DATA),
        .NB_OP(NB_OP)
    ) alu (
        .i_dataA(i_dataA),
        .i_dataB(i_dataB),
        .i_op(i_op),
        .o_result(o_result),
        .o_overflow(o_overflow)
    );
          
    initial begin
     
        operation[0] = ADD;
        operation[1] = SUB;
        operation[2] = AND;
        operation[3] = OR;
        operation[4] = XOR;
        operation[5] = SRA;
        operation[6] = SRL;
        operation[7] = NOR;
   
        $display("--------------------------------------");
        $display("----------Initiating Tests------------");
        for(op_cont = 0; op_cont < 8 ; op_cont = op_cont + 1) begin
            for(tests_cont = 0; tests_cont < N_TEST; tests_cont = tests_cont + 1) begin
               
                i_dataA = $random % 256 - 128; // Números entre -128 y 127
                i_dataB = $random % 256 - 128; // Números entre -128 y 127
                i_op = operation[op_cont];
                #10;
                case(i_op)                 
                    ADD: if ((i_dataA + i_dataB) != o_result) begin
                            $display("Test FAILED: ADD | %d + %d = %d (expected %d)", i_dataA, i_dataB, o_result, i_dataA + i_dataB);
                         end else begin
                            $display("Test PASSED: ADD | %d + %d = %d | Overflow: %b", 
                                  $signed(i_dataA), $signed(i_dataB), $signed(o_result), o_overflow);

                         end
                    SUB: if ((i_dataA - i_dataB) != o_result) begin
                            $display("Test FAILED: SUB | %d - %d = %d (expected %d)", i_dataA, i_dataB, o_result, i_dataA - i_dataB);
                      
                         end else begin
                           $display("Test PASSED: SUB | %d - %d = %d | Overflow: %b", 
                                  $signed(i_dataA), $signed(i_dataB), $signed(o_result), o_overflow);
                         end
                    AND: if ((i_dataA & i_dataB) != o_result) begin
                             $display("Test FAILED: AND | %b & %b = %b (expected %b)", i_dataA, i_dataB, o_result, (i_dataA & i_dataB));
                          
                         end else begin
                            $display("Test PASSED: AND | %b & %b = %b", i_dataA, i_dataB, o_result);
                         end
                    OR:  if ((i_dataA | i_dataB) != o_result) begin
                          $display("Test FAILED: OR | %b | %b = %b (expected %b)", i_dataA, i_dataB, o_result, (i_dataA | i_dataB));
                      
                         end else begin
                             $display("Test PASSED: OR | %b | %b = %b", i_dataA, i_dataB, o_result);
                         end
                    XOR: if ((i_dataA ^ i_dataB) != o_result) begin
                      $display("Test FAILED: XOR | %b ^ %b = %b (expected %b)", i_dataA, i_dataB, o_result, (i_dataA ^ i_dataB));
                          
                         end else begin
                           $display("Test PASSED: XOR | %b ^ %b = %b", i_dataA, i_dataB, o_result);
                         end
                    NOR: if ((~(i_dataA | i_dataB)) != o_result) begin
                        $display("Test FAILED: NOR | ~(%b | %b) = %b (expected %b)", i_dataA, i_dataB, o_result, ~(i_dataA | i_dataB));
                        
                         end else begin
                           $display("Test PASSED: NOR | ~(%b | %b) = %b", i_dataA, i_dataB, o_result);
                         end
                    SRA:begin
                   
                     if ((i_dataA >>> i_dataB) != o_result) begin
                       $display("Test FAILED: SRA | %b >>> %b = %b (expected %b)", i_dataA, i_dataB, o_result, (i_dataA >>> i_dataB));
                         
                         end else begin
                         $display("Test PASSED: SRA | %b >>> %b = %b", i_dataA, i_dataB, o_result);
                      
                         end
                         end
                    SRL: if ((i_dataA >> i_dataB) != o_result) begin
                            $display("Test FAILED: SRL | %b >> %b = %b (expected %b)", i_dataA, i_dataB, o_result, (i_dataA >> i_dataB));
                           
                         end else begin
                             $display("Test PASSED: SRL | %b >> %b = %b", i_dataA, i_dataB, o_result);
                         end
                    default: $display("Invalid Operation Code: %b", operation[op_cont]);
                endcase            
            end
            $display("------------Test for Operation %b Finished---------------", operation[op_cont]);         
        end
       $finish;
    end
endmodule
