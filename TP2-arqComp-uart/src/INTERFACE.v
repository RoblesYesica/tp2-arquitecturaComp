`timescale 1ns / 1ps
module INTERFACE #(
    parameter NB_DATA   = 8,
    parameter NB_OP = 6
) (
    input wire i_clock,
    input wire i_reset,
    input wire i_rx_done,
    input wire i_tx_done,
    input wire [NB_DATA-1:0] i_rx_data,
    input wire [NB_DATA-1:0] i_alu_result,
    output wire [NB_DATA-1:0] o_tx_data,
    output wire [NB_DATA-1:0] o_dataA,
    output wire [NB_DATA-1:0] o_dataB,
    output wire [5:0] o_operation,
    output wire o_tx_enable
);

  // estados
  localparam IDLE = 2'b00;
  localparam DATA= 2'b01;
  localparam STOP = 2'b10;
 

  // contador para controlar qué cargar
  reg [1:0] op_counter, next_op_counter;

  reg [1:0] state, next_state;
  reg [NB_DATA-1:0] alu_dataA, next_alu_dataA;
  reg [NB_DATA-1:0] alu_dataB, next_alu_dataB;
  reg [NB_OP-1:0] alu_operation, next_alu_operation;
  reg [NB_DATA-1:0] tx_data, next_tx_data;
  reg tx_enable, next_tx_enable;
  reg alu_data_ready, next_alu_data_ready; // Señal de validación para el dato de la ALU

  always @(posedge i_clock) begin
    if (i_reset) begin
      state <= IDLE;
      alu_dataA <= 0;
      alu_dataB <= 0;
      alu_operation <= 0;
      tx_data <= 0;
      tx_enable <= 0;
      op_counter <= 0;
      alu_data_ready <= 0;
    end else begin
      state <= next_state;
      alu_dataA <= next_alu_dataA;
      alu_dataB <= next_alu_dataB;
      alu_operation <= next_alu_operation;
      tx_data <= next_tx_data;
      tx_enable <= next_tx_enable;
      op_counter <= next_op_counter;
      alu_data_ready <= next_alu_data_ready; // Se propaga la señal de validación
    end
  end

  always @(*) begin
    next_state = state;
    next_alu_dataA = alu_dataA;
    next_alu_dataB = alu_dataB;
    next_alu_operation = alu_operation;
    next_tx_data = tx_data;
    next_tx_enable = 1'b0;
    next_op_counter = op_counter;
    next_alu_data_ready = alu_data_ready; // Mantener el valor actual por defecto
    case (state)
      IDLE: begin
        if (i_rx_done) begin
            if(op_counter==2'b00 || op_counter==2'b01 || op_counter==2'b10) begin
              next_state = DATA;
//            end else if (op_counter == 2'b11) begin
//               next_state = STOP;
            end
        end
      end      
       
      DATA: begin
//        if (i_rx_done) begin  comente este
          case (op_counter)
            2'b00: begin
              next_alu_dataA = i_rx_data; // Cargar dato A
              next_op_counter = op_counter + 1;
              next_state = IDLE;  // Volver a IDLE para esperar la próxima entrada
            end
            2'b01: begin
              next_alu_dataB = i_rx_data; // Cargar dato B
              next_op_counter = op_counter + 1;
              next_state = IDLE;  // Volver a IDLE para esperar la próxima entrada
            end
            2'b10: begin
              next_alu_operation = i_rx_data[NB_OP-1:0]; // Cargar operador
              next_op_counter = op_counter + 1;
              next_state = STOP;  // Volver a IDLE para esperar la próxima entrada
              next_alu_data_ready = 1'b1; // Dato de la ALU está listo
            end
            default: begin    
              // Mantenerse en DATA hasta que todos los datos estén cargados
              next_state = IDLE;         
            end
          endcase
        //  next_state = IDLE;
        end
//      end comente este

      STOP: begin
       if (alu_data_ready) begin
          next_tx_data = i_alu_result;   // Asignar resultado de la ALU
        end
        
        next_tx_enable = 1'b1;            // Iniciar transmisión
        if (i_tx_done) begin  // Solo cambiar de estado cuando la transmisión esté completa
          next_op_counter = 2'b00;       // Resetear el contador de operaciones
          next_state = IDLE;             // Regresar a IDLE después de transmitir
        end else begin
          next_state = STOP;             // Mantenerse en STOP hasta que la transmisión termine
        end
      end
      
      default: next_state = IDLE;
    endcase
  end

 assign o_dataA = alu_dataA;
 assign o_dataB = alu_dataB;
 assign o_operation = alu_operation;
 assign o_tx_data = tx_data;
 assign o_tx_enable = tx_enable;
endmodule
