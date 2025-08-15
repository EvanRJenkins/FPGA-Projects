`timescale 1ns/1ns

module uart_tb (


);

parameter c_CLOCKS_PER_BIT = 1302;
parameter c_CLOCK_PERIOD = 20;

reg           r_clk_sig = 1'b0;
reg           r_tx_data_valid;
reg [7:0]     r_tx_data = 8'h3F;
wire          w_tx_bit;
wire          w_tx_active;
wire          w_tx_done;
reg [7:0]     r_result_byte;
reg           r_prev_tx_bit = 1'b1; // for falling edge detect


always
begin
  
  // Invert clk every 10 ns to make 50 MHz clk
  #(c_CLOCK_PERIOD / 2) r_clk_sig <= !r_clk_sig;
  
end

initial
begin
  $monitor("Time: %0t w_tx_bit: %b", $time, w_tx_bit);
end

initial
begin
  
  r_tx_data_valid <= 1'b1;
  #1000
  
  r_tx_data_valid <= 1'b0;
end

// Track previous TX line for edge detection
always @(posedge r_clk_sig)
begin
  r_prev_tx_bit <= w_tx_bit;
end

always @(w_tx_bit or r_prev_tx_bit)  // Run this only when tx transitions HIGH to LOW
begin
  
  if (r_prev_tx_bit == 1'b1 && w_tx_bit == 1'b0) 
  begin
    
    RECEIVE_BYTE(8'h3F);
  
  end
  
end



task RECEIVE_BYTE (

  input [7:0] test_byte

);

  integer k;
  
  begin
    
    // Align with middle of bit
    #((c_CLOCKS_PER_BIT * c_CLOCK_PERIOD) / 2);
    
    // Wait for next bit
    #(c_CLOCKS_PER_BIT * c_CLOCK_PERIOD);
    
    //receive bits
    for (k = 0; k < 8; k = k + 1)
    begin
    
      // Sample tx bit
      r_result_byte[k] = w_tx_bit;
        
      // Wait
      #(c_CLOCKS_PER_BIT * c_CLOCK_PERIOD);
        
    end
    
    $display("Result Byte: %h", r_result_byte);
    #100;
    $finish;
  end

endtask


uart_tx #(.CLOCKS_PER_BIT(c_CLOCKS_PER_BIT)) tx_inst (

  .i_clk(r_clk_sig),
  .i_tx_data_valid(r_tx_data_valid),
  .i_tx_data(r_tx_data),
  .o_tx_bit(w_tx_bit),
  .o_tx_active(w_tx_active),
  .o_tx_done(w_tx_done)

);


endmodule