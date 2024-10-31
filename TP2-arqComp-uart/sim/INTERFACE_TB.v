`timescale 1ns / 1ps
module INTERFACE_TB;
  // Parámetros
  parameter NB_DATA = 8;
  parameter NB_OP = 6;

  // Señales de entrada
  reg i_clk;
  reg i_reset;
  reg i_rx_done;
  reg i_tx_done;
  reg [NB_DATA-1:0] i_rx_data;

  // Señales de salida
  wire [NB_DATA-1:0] o_tx_data;
  wire [NB_OP-1:0] o_alu_op;
  wire [NB_DATA-1:0] o_alu_dataA;
  wire [NB_DATA-1:0] o_alu_dataB;
  wire o_tx_enable;

  // Resultado de la ALU
  wire [NB_DATA-1:0] o_result;

  // Instancia del DUT (Device Under Test)
  INTERFACE #(
    .NB_DATA(NB_DATA),
    .NB_OP(NB_OP)
  ) uut (
    .i_clock(i_clk),
    .i_reset(i_reset),
    .i_rx_done(i_rx_done),
    .i_tx_done(i_tx_done), 
    .i_rx_data(i_rx_data),
    .i_alu_result(o_result),
    .o_tx_data(o_tx_data),  
    .o_dataA(o_alu_dataA),
    .o_dataB(o_alu_dataB),
    .o_operation(o_alu_op),
    .o_tx_enable(o_tx_enable)
  );

  // Instancia de la ALU
  ALU #(
    .NB_DATA(NB_DATA),
    .NB_OP(NB_OP)
  ) u_alu (
    .i_operation(o_alu_op),
    .i_data_a(o_alu_dataA),
    .i_data_b(o_alu_dataB),
    .o_result(o_result)
  );

  // Generar un reloj de 10ns de período
  always begin
    #10 i_clk = ~i_clk;
  end

  // Inicialización de señales
  initial begin
    // Inicialización de señales
    i_clk = 0;
    i_reset = 1;
    i_rx_done = 0;
    i_rx_data = 0;
    i_tx_done = 0;
    

    // Reset del sistema
    #100;
    i_reset = 0;

    // Simulación: Cargar datos A y B, y el operador ALU
    #40;
    i_rx_done = 1;
    i_rx_data = 8'b00000001; // Dato A
    
    #40;
    i_rx_done = 0;

    #40;
    i_rx_done = 1;
    i_rx_data = 8'b00000011; // Dato B
    
    #40;
    i_rx_done = 0;

    #40;
     i_rx_done = 1;
    i_rx_data = 8'b00100000; // Operador ALU (por ejemplo, suma)
   
    #40;
    i_rx_done = 0;
   

    // Esperar el resultado de la ALU
//    #20;
   #2000;
  
  end
  // Mostrar las señales para depuración
initial begin
  $monitor("Time=%0t, State=%b, Counter=%d, ALU Op=%h, ALU Data A=%h, ALU Data B=%h, Tx Enable=%b, Tx Data=%h",
            $time, uut.state, uut.op_counter, o_alu_op, o_alu_dataA, o_alu_dataB, o_tx_enable, o_tx_data);
end

  // Mostrar las señales para depuración
//  initial begin
//    $monitor("Time=%0t, Reset=%b, RxDone=%b, RxData=%h, TxData=%h, AluOp=%h, AluDataA=%h, AluDataB=%h, TxStart=%b, Result=%h",
//              $time, i_reset, i_rx_done, i_rx_data, o_tx_data, o_alu_op, o_alu_data_A, o_alu_data_B, o_tx_start, o_result);
              
//               $monitor("Time: %0t | state: %b | counter: %d| alu_data %d", $time,
//                uut.state,uut.op_counter,uut.i_alu_data_out);
//  end
  
   // Monitoreo de la señal tx_done para finalizar la simulación
   always @(posedge i_clk) begin
      if (o_tx_enable == 1'b1) begin
      #100
        // Comprobamos si el dato se transmite correctamente
        $display("Transmitiendo: %h", o_tx_data);
        $finish;
        end
          // Comprobar el resultado de la ALU
//    #200;
//    if (o_tx_data !== o_result) begin
//      $display("Error: o_tx_data = %h, expected = %h", o_tx_data, o_result);
//    end else begin
//      $display("Test Passed: o_tx_data = %h, expected = %h", o_tx_data, o_result);
        end
//         $display("------ Fin ! ------");
//          #2000; //se simula la transimision
         
//         $finish;
//      end
//   end

endmodule



