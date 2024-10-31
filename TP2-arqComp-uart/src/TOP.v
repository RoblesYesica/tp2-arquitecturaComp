module TOP #(
    parameter NB_DATA   = 8,
    parameter NB_OP = 6,
    parameter CLOCK      = 50E6,
    parameter BAUD_RATE = 19200,
    parameter SB_TICK = 16
) (
    input  wire i_clock,
    input  wire i_reset,
    input  wire i_rx,
    output wire o_tx
);


  // UART
  wire tick;
  wire rx_done;
  wire [NB_DATA-1:0] rx_data;
  
  wire [NB_DATA-1:0] tx_data;
  wire tx_enable;
  
  wire tx_done;
 
  // ALU
  wire [NB_DATA-1:0] alu_result;
  wire [NB_DATA-1:0] alu_dataA;
  wire [NB_DATA-1:0] alu_dataB;
  wire [NB_OP-1:0] alu_operation;


 BAUD_RATE_GENERATOR #(
      .BAUD_RATE(BAUD_RATE),
      .CLOCK(CLOCK)
     
  )  baud_rate_generator_instance (
      .i_clock  (i_clock),
      .i_reset(i_reset),     
      .o_br_clock (tick)
  );

  RX_UART #(
      .NB_DATA(NB_DATA),
      .SB_TICK(SB_TICK)
  )  rx_uart_instance (
      .i_clock(i_clock),
      .i_s_tick(tick),
      .i_reset(i_reset),     
      .i_rx(i_rx),
      .o_rx_data(rx_data),
      .o_rx_done(rx_done)
  );
   

  TX_UART #(
      .NB_DATA(NB_DATA),
      .SB_TICK (SB_TICK) 
  ) tx_uart_instance (
      .i_clock(i_clock),
      .i_reset(i_reset),
      .i_s_tick(tick),
      .i_tx_data(tx_data),  
      .i_tx_start(tx_enable),      
      .o_tx(o_tx),
      .o_tx_done(tx_done)
  );


 INTERFACE #(
      .NB_DATA  (NB_DATA),
      .NB_OP(NB_OP)
  ) interface_instance (
      .i_clock(i_clock),
      .i_reset(i_reset),
      .i_rx_data(rx_data),
      .i_rx_done(rx_done),
      .i_alu_result(alu_result),
      
      .i_tx_done(tx_done),
                
      .o_dataA(alu_dataA),
      .o_dataB(alu_dataB),
      .o_operation(alu_operation),
      .o_tx_data(tx_data),
      .o_tx_enable(tx_enable)
  );


  ALU #(
      .NB_OP  (NB_OP),
      .NB_DATA(NB_DATA)
  ) alu_instance (
      .i_operation(alu_operation),
      .i_data_a(alu_dataA),
      .i_data_b(alu_dataB),
      .o_result(alu_result)
  );

 

endmodule
