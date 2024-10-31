`timescale 1ns / 1ps
module TOP2_TB;
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
  
  reg signed [NB_DATA-1:0] expected_result;
  reg signed [NB_DATA-1:0] random_a;
  reg signed [NB_DATA-1:0] random_b;
  
  localparam ADD_OP = 6'b100000;
  localparam SUB_OP = 6'b100010;
  localparam AND_OP = 6'b100100;
  localparam OR_OP = 6'b100101;
  localparam XOR_OP = 6'b100110;
  localparam SRA_OP = 6'b000011;
  localparam SRL_OP = 6'b000010;
  localparam NOR_OP = 6'b100111;

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

  // Generar reloj de 20ns de período (50 MHz)
  always begin
    #10 i_clock = ~i_clock;
  end

  initial begin
    // Inicialización de señales
    i_clock = 0;
    i_reset = 1;
    i_rx = 1; // Estado inactivo de UART RX
    
    // Resetear el sistema
    #100;
    i_reset = 0;
    #200;

    // Simulación de la generación de números aleatorios y envío de la operación
    send_and_check_operation(ADD_OP);
    send_and_check_operation(SUB_OP);
    send_and_check_operation(AND_OP);
    send_and_check_operation(OR_OP);
    send_and_check_operation(XOR_OP);
    send_and_check_operation(SRA_OP); //conserva el signo
    send_and_check_operation(SRL_OP); //insertar 0
    send_and_check_operation(NOR_OP);

    #10000;
    $finish;
  end

  // Tarea para enviar operación y verificar resultado
  task send_and_check_operation(input [NB_OP-1:0] operation);
    begin
      random_a =  $random % 256; // Número aleatorio de 8 bits    
      uart_send_byte(random_a);  // Enviar operando A
      #2000;
      random_b = $random % 8; // Número aleatorio de 8 bits
      if (random_b < 0) begin
         random_b = random_b + 8;
       end
      uart_send_byte(random_b);  // Enviar operando B
      #2000;
      uart_send_byte(operation); // Enviar operación
      #2000;
      // Esperar a que se procese la operación
      #52160;
      wait (uut.tx_uart_instance.o_tx_done == 1'b1);  
      // Calcular el resultado esperado
      case (operation)
        ADD_OP: expected_result = random_a + random_b;
        SUB_OP: expected_result = random_a - random_b;
        AND_OP: expected_result = random_a & random_b;
        OR_OP:  expected_result = random_a | random_b;
        XOR_OP: expected_result = random_a ^ random_b;
        SRA_OP: expected_result = random_a >>> random_b;
        SRL_OP: expected_result = random_a >> random_b;
        NOR_OP: expected_result = ~(random_a | random_b);
        default: expected_result = 8'b0;
      endcase

      // Mostrar información detallada del test
      if (uut.interface_instance.o_tx_data === expected_result) begin
        $display("Test PASSED: Op = %b | A = %d | B = %d | Expected = %b | Got = %b", 
                 operation, random_a, random_b, expected_result, uut.interface_instance.o_tx_data);
      end else begin
        $display("Test FAILED: Op = %b | A = %d | B = %d | Expected = %b | Got = %b", 
                 operation, random_a, random_b, expected_result, uut.interface_instance.o_tx_data);
      end
    end
  endtask

  // Tarea para enviar un byte por UART simulada
  task uart_send_byte(input [7:0] data);
    integer i;
    begin
      #22820 i_rx = 0; // Bit de start (nivel bajo)
      
      // Enviar los 8 bits de datos, LSB primero
      for (i = 0; i < 8; i = i + 1) begin
        #52160 i_rx = data[i];
      end
      
      // Bit de stop (nivel alto)
      #52160 i_rx = 1;
    end
  endtask

endmodule

