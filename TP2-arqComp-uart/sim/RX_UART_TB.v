`timescale 1ns / 1ps
module RX_UART_TB();
   // Parameters
   parameter CLOCK      = 50E6;
   parameter BAUD_RATE = 19200;
   parameter NB_DATA = 8;
   parameter SB_TICK = 16; //Ticks para los bits de STOP
 
   // Señales
   reg clock;
   reg reset;
   reg i_rx;
   wire tick;
   wire             rx_done;
   wire [NB_DATA-1:0] data_out;
   reg [2:0] i;
   
//   reg [NB_DATA-1:0] data_rx;
   localparam [NB_DATA-1:0] data_rx= 8'b10101110;  // Un número binario de 8 bits 
    // Instantiate the RX_UART module
    RX_UART
    #(
        .NB_DATA(NB_DATA), .SB_TICK(SB_TICK)
     ) 
     u_rx_uart
     (
        .i_clock(clock), .i_reset(reset),
        .i_rx(i_rx), .i_s_tick(tick),
        .o_rx_done(rx_done), .o_rx_data(data_out)
     );
// Instantiate the BAUDRATE_GENERATOR module
 BAUD_RATE_GENERATOR #(
    .BAUD_RATE(BAUD_RATE),
    .CLOCK (CLOCK)
  ) DUT (
    .i_clock(clock),
    .i_reset(reset),
    .o_br_clock(tick)
  );   
  initial begin
    reset = 1'b1;
    clock = 1'b0;
    i_rx  = 1'b1;   // Inactivo
    #20000;   
     reset = 1'b0;
     i_rx  = 1'b0;// Inicio de transmisión estado START //espera 7 ticks 
    
     for(i = 0; i < NB_DATA-1; i = i + 1) begin //Envio de datos bit a bit estado DATA
            #52160 i_rx = data_rx[i];   //espera 16 ticks para leer un nuevo bits del menos al mas significativo            
     end         
    #52160 i_rx = 1'b1; //estado STOP //espera 16 ticks
        
end

  always @(posedge clock)
    begin
        if(rx_done == 1)
       begin
            $display("------ Fin de la recepcion! ------");
            $finish;
       end
   end
   initial begin
   $monitor("Time: %0t | i_rx: %b | data_out: %b | rx_done_tick: %b", $time, i_rx, data_out, rx_done);
//   $monitor("Time: %0t | state: %b ", $time, u_rx_uart.state);
   end

    always #10 clock = ~clock;
endmodule
   /*
     * cada 163 ciclos de reloj se produce 1 tick
     * hay que contar 16 ticks, entonces
     * 163*16 = 2608
     *
     * 1 ciclo            -> 20ns
     * 163 ciclos (1tick) -> 52160ns
     */