`timescale 1ns/1ns  // Set timescale and precision. Precision should be > or = to timescale (rule of thumb)

module uart_rx_tb ();

// Simulation parameters
parameter c_CLOCKS_PER_BIT = 1302;



wire [7:0] w_rx_byte;
reg r_clk_sig = 0;
reg r_rx_bit = 1;

initial  // Initialize simulation signals 
begin
  
  // Send byte 0x3F to receiver
  #10;
  SEND_BYTE(8'h3F);
  #20000;
  $display("%d", w_rx_byte);
  
end

// Generate Clock signal by inverting clk_sig every CLOCK_PERIOD
always
begin
  #10 r_clk_sig <= !r_clk_sig;
end

// Task to send a byte to the receiver
task SEND_BYTE (

  input [7:0] i_data

);

  integer     k;
  begin
    
    
    // Send the start bit
    r_rx_bit <= 1'b0;
    #(c_CLOCKS_PER_BIT * 20);

    // Instantiate uart_rx module to be tested
    for (k = 0; k < 8; k = k + 1)
    begin
      r_rx_bit <= i_data[k];
      #(c_CLOCKS_PER_BIT * 20);
    end
    
    // Send stop bit
    r_rx_bit <= 1'b1;
    #(c_CLOCKS_PER_BIT * 20);
  end
endtask

uart_rx #(.CLOCKS_PER_BIT(1302)) test_rx (

  .i_clk(r_clk_sig),
  .i_rx_bit(r_rx_bit),
  .o_rx_data_valid(),
  .o_rx_byte(w_rx_byte)

);


endmodule


