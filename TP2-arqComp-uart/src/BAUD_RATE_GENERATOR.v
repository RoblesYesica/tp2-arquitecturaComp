`timescale 1ns / 1ps
module BAUD_RATE_GENERATOR 
    #(
      parameter CLOCK      = 50E6,
      parameter BAUD_RATE = 19200
    )
    (
     input wire i_clock,
     input wire i_reset,
     output wire o_br_clock
    
     );

localparam integer N_CONT = CLOCK/(BAUD_RATE*16);
localparam integer N_BITS = $clog2(N_CONT);

reg [N_BITS - 1:0] count;

always @(posedge i_clock) begin
    if(i_reset)begin
        count <= {N_BITS{1'b0}};
    end
    else begin
        if(count < N_CONT-1)
            count <= count + 1;
        else
            count <= {N_BITS{1'b0}};
    end    
end

assign o_br_clock = (count==N_CONT-1)? 1'b1 : 1'b0;

endmodule
