`timescale 1ns / 1ps
module BAUD_RATE_GENERATOR_TB();
    parameter CLOCK      = 50E6;
    parameter BAUD_RATE = 19200;
//    Señales
  reg i_clock;
  reg i_reset;
  wire o_tick;


 
  BAUD_RATE_GENERATOR #(
    .BAUD_RATE(BAUD_RATE),
    .CLOCK (CLOCK)
  ) uut (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .o_br_clock(o_tick)
   
  );
  
//   Generación de reloj
  always #10 i_clock = ~i_clock; // 50 MHz -> Periodo de 20ns
   // initial begin
   //     i_clock = 0;
     //   forever #10 i_clock = ~i_clock;       
   // end
  
  initial begin
    i_clock = 1'b0;
    i_reset = 1'b1;
  
    
    #10;
    i_reset = 1'b0;
   
//Simulación de 100 milisegundos (suficiente para ver varios ciclos)
    #10000;
    
    $finish;
  end
  
//   Monitorear las señales y parámetros
  initial begin
//     Valores de N_CONT y N_BITS
    $display("N_CONT: %d", uut.N_CONT);
    $display("N_BITS: %d", uut.N_BITS);

//     Monitorear los cambios del contador y del o_br_clock
    $monitor("Time: %0t | count: %d | o_br_clock: %b", $time, uut.count, o_tick);
  end
endmodule
///*
// * cada 163 ciclos de reloj se produce 1 tick
// * hay que contar 16 ticks, entonces
// * 163*16 = 2608
// *
// * 1 ciclo            -> 20ns
// * 163 ciclos (1tick) -> 52160ns
// */ 
