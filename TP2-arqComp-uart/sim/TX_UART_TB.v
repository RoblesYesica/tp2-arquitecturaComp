`timescale 1ns / 1ps
module TX_UART_TB();

 // Parameters
   parameter CLOCK      = 50E6;
   parameter BAUD_RATE  = 19200;
   parameter NB_DATA    = 8;
   parameter SB_TICK    = 16; // Ticks para los bits de STOP
 
   // Señales
   reg clock;
   reg reset;
   reg tx_start;
   wire tick;
   wire tx_done;
   reg [NB_DATA-1:0] data;
   wire tx;

   // Instancia del módulo TX_UART (solo conexiones por nombre)
   TX_UART
   #(
        .NB_DATA(NB_DATA), .SB_TICK(SB_TICK)
   ) 
   u_tx_uart (
        .i_clock(clock),
        .i_reset(reset),
        .i_tx_start(tx_start),
        .i_s_tick(tick),
        .i_data(data),
        .o_tx_done_tick(tx_done),  // Cambiado de rx_done a tx_done
        .o_tx(tx)
   );
   
   // Instancia del BAUD_RATE_GENERATOR (también por nombre)
   BAUD_RATE_GENERATOR #(
      .BAUD_RATE(BAUD_RATE),
      .CLOCK(CLOCK)
   ) DUT (
      .i_clock(clock),
      .i_reset(reset),
      .o_br_clock(tick)
   );  

   // Generador de reloj (50 MHz)
   always #10 clock = ~clock; 

   // Estímulos iniciales
   initial begin
      reset = 1'b1;
      clock = 1'b0;
      tx_start = 1'b0;
      data = 8'b0;
      #20 reset = 1'b0;   // Liberar reset
      #52160 tx_start = 1'b1;  // Iniciar transmisión
      data = 8'b10101110;      // Dato a enviar
      #20 tx_start = 1'b0;     // Finalizar start después de un ciclo
   end

   // Monitoreo de la señal tx_done para finalizar la simulación
   always @(posedge clock) begin
      if (tx_done == 1'b1) begin
         $display("------ Fin de la transmision! ------");
         $finish;
      end
   end

endmodule

