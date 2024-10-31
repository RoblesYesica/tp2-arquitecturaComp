//`timescale 1ns / 1ps
module TOP_TB;
  // Parámetros
  parameter NB_DATA = 8;
  parameter NB_OP = 6;
  parameter CLOCK = 50E6;      // 50 MHz
  parameter BAUD_RATE = 19200; // Tasa de baudios

  // Señales de entrada
  reg i_clock;
  reg i_reset;
  reg i_rx;

  // Señales de salida
  wire o_tx;
 
   reg [3:0] i;
  
  // Instancia del DUT (Device Under Test)
  TOP #(
    .NB_DATA(NB_DATA),
    .NB_OP(NB_OP),
    .CLOCK(CLOCK),
    .BAUD_RATE(BAUD_RATE)
  ) uut (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_rx(i_rx),
    .o_tx(o_tx)
  );

  // Generar un reloj de 20ns de período (50 MHz)
  always begin
    #10 i_clock = ~i_clock;
  end
// Inicialización de las señales
  initial begin
    // Inicialización de señales
    i_clock = 0;
    i_reset = 1;
    i_rx = 1; // Estado inactivo de UART RX
    
    // Resetear el sistema
    #100;
    i_reset = 0;
    #200;
  
    uart_send_byte(8'b00000101); // Dato A     
          
          
      #2000; // Esperar el tiempo necesario para que la transmisión de UART se complete
   
    // Segundo dato: operando B
    uart_send_byte(8'b00000110); // Dato B: 2
     #2000;
    
    // Tercer dato: operación ALU (por ejemplo, suma)
    uart_send_byte(8'b00100000); // Operación de suma (código binario para ADD)
     #2000;
//     #52160;
//     $display("Transmitiendo 4 : %h",uut.tx_uart_instance.i_tx_start); 
       #52160;
    wait (uut.tx_uart_instance.o_tx_done == 1'b1);  
     $display("FIN de la transmision o_tx_done = %b",uut.tx_uart_instance.o_tx_done); 
   $finish;
   
//   $display("Transmitiendo: %h",uut.interface_instance.o_tx_data);
//   #52160;
  end

  // Tarea para enviar un byte por UART simulada
  task uart_send_byte(input [7:0] data);
//    integer i;
    begin
      // Inicio de transmisión (bit de start, nivel bajo)
     #22820 i_rx = 0;
//        #5208; // 1 bit (a 19200 baudios)
      
      // Enviar los 8 bits de datos, LSB primero
      for (i = 0; i < 8; i = i + 1) begin
         #52160 i_rx = data[i];
//        #52160; // Tiempo de un bit a 19200 baudios
      end
      
      // Bit de stop (nivel alto)
       #52160 i_rx = 1;
    
    end
  endtask

  

//   Monitorización de las señales principales
  initial begin
    $monitor("Time=%0t | Data A=%b | Data B=%b |  ALU Op=%b | ALU Result=%b | Tx Enable=%b | Tx Data=%b | o_tx=%b ",
             $time,  uut.interface_instance.o_dataA, uut.interface_instance.o_dataB,uut.interface_instance.o_operation,
              uut.alu_instance.o_result, uut.interface_instance.o_tx_enable, 
             uut.interface_instance.o_tx_data, o_tx);
  end
  //monitoreo el modulo INTERFACE
//  initial begin
//    $monitor("Time=%0t | interface i_rx_data=%b| interface i_rx_done=%b|interface Op=%b | interface Data A=%h | interface Data B=%h | ALU Result=%h | interface Tx Enable=%b | interface Tx Data=%h",
//             $time, uut.interface_instance.i_rx_data,uut.interface_instance.i_rx_done,
//            uut.interface_instance.o_operation, uut.interface_instance.o_dataA, 
//             uut.interface_instance.o_dataB, uut.interface_instance.i_alu_result,
//            uut.interface_instance.o_tx_enable, uut.interface_instance.o_tx_data);
// end
   //monitoreo el modulo ALU
//  initial begin
//    $monitor("Time=%0t | ALU Op=%b | Data A=%h | Data B=%h | ALU Result=%h ",
//             $time, uut.alu_instance.i_operation, uut.alu_instance.i_data_a, 
//             uut.alu_instance.i_data_b, uut.alu_instance.o_result);
//  end
//monitoreo el modulo RX
// initial begin
//   $monitor("Time: %0t | recepcion o_rx_data: %b | o_rx_done %b", 
//   $time, uut.rx_uart_instance.o_rx_data, uut.rx_uart_instance.o_rx_done);
//  end
  
  //monitoreo el modulo TX
//  initial begin
//    $monitor("Time=%0t | tx i_tx_data=%b| tx i_tx_start=%b|tx o_tx_done=%b | tx o_tx=%b",
//             $time, uut.tx_uart_instance.i_tx_data,uut.tx_uart_instance.i_tx_start,
//            uut.tx_uart_instance.o_tx_done, uut.tx_uart_instance.o_tx);
          
// end
//   always @(posedge i_clock) begin
//      if ( uut.interface_instance.o_tx_enable == 1'b1) begin
//     #100
//         Comprobamos si el dato se transmite correctamente
//        $display("Transmitiendo: %h",uut.interface_instance.o_tx_data);
//        #100
//       $finish;
//        end
//  end
  
//  always @(posedge i_clock) begin
//      if ( uut.rx_uart_instance.o_rx_done == 1'b1) begin
//      #100
//         Comprobamos si el dato se transmite correctamente
//        $display("RECEPCION : %h", uut.rx_uart_instance.o_rx_data);
//        $finish;
//        end
//  end

endmodule

