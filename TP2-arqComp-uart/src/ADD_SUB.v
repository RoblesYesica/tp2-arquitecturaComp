`timescale 1ns / 1ps
module ADD_SUB#(
    parameter NB_DATA = 8
    )
    (
    input  wire signed [NB_DATA-1:0]  i_dataA, // Primer operando (8 bits con signo) Rango -128 a 127
    input  wire signed [NB_DATA-1:0] i_dataB, // Segundo operando (8 bits con signo)
    input  wire ctrl,                // Control: 0 para suma, 1 para resta
    output wire signed [NB_DATA-1:0] o_result,  // Resultado de la operación con signo
    output wire o_overflow            // Señal de overflow para números con signo
    );
    
    reg signed [NB_DATA-1:0] tmpResult;   
    reg tmpOverflow; 

always @(*) begin
       if (ctrl) begin
          tmpResult = i_dataA - i_dataB;
                 //Check overflow for subtraction
           tmpOverflow = (i_dataA[NB_DATA-1] != i_dataB[NB_DATA-1]) && 
                        (tmpResult[NB_DATA-1] != i_dataA[NB_DATA-1]);
               
        end else begin
            tmpResult = i_dataA + i_dataB;
                 //Check overflow for addition
            tmpOverflow = (i_dataA[NB_DATA-1] == i_dataB[NB_DATA-1]) && 
                         (tmpResult[NB_DATA-1] != i_dataA[NB_DATA-1]);   
       end 
  end 
      
    assign o_overflow = tmpOverflow;
    assign o_result =tmpResult;
    
endmodule
