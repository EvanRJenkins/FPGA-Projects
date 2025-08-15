module uart_rx #(parameter CLOCKS_PER_BIT = 1302)
(

  // Module Inputs
  input         i_clk,
  input         i_rx_bit,
  
  // Module Outputs
  output        o_rx_data_valid,
  output [7:0]  o_rx_byte

);

// Parameters

// State Definitions
localparam IDLE_STATE      = 3'b000;  // Wait until i_rx_bit line goes low, go to START_STATE if it does
localparam START_STATE     = 3'b001;  // Wait for ((CLOCKS_PER_BIT - 1) / 2) cycles. If i_rx_bit is still low, go to RECEIVE_STATE when clock count == CLOCKS_PER_BIT
localparam RECEIVE_STATE   = 3'b010;  // Wait for CLOCKS_PER_BIT - 1 cycles, get next bit, ++bit index. If bit index == 7, go to STOP_STATE
localparam STOP_STATE      = 3'b011;  // Receive STOP_BIT, go to CLEANUP_STATE
localparam CLEANUP_STATE   = 3'b100;  // Set o_rx_data_valid for one cycle, do housekeeping

// Internal Registers
reg [10:0]  r_clk_counter;
reg [2:0]   r_bit_index;
reg [2:0]   r_state;
reg         r_rx_data_valid;
reg [7:0]   r_rx_byte;
reg         r_rx_bit;


always @(posedge i_clk)  // SYCNCHRONIZE asynchronous input signal to module clock domain before using in module process
begin
  r_rx_bit <= i_rx_bit;
end


// Main State Logic
always @(posedge i_clk)
begin
  
  case (r_state)

    IDLE_STATE:
    begin
      // Turn off data valid, reset clock counter
      r_rx_data_valid <= 1'b0;
      r_clk_counter <= 'b0;
      r_bit_index <= 3'b000;
      
      // Wait for start bit 
      if (i_rx_bit == 1'b0)
      begin
        r_state <= START_STATE;
      end
      
      // Stay while not start bit
      else
      begin
        r_state <= IDLE_STATE;
      end
    end
    
    START_STATE:
    begin
      
      // Wait until middle of bit
      if (r_clk_counter == (CLOCKS_PER_BIT - 1) / 2)
      begin
        
        // Check if still start bit
        if (r_rx_bit == 0)
         
          // If still start bit, reset count and go to RECEIVE_STATE
          begin
          r_state <= RECEIVE_STATE;
          r_clk_counter <= 'b0;
          end
        
        else
          
          // If not, go back to idle
          begin
            r_state <= IDLE_STATE;
          end
        
      end
      
      // Else, ++r_clk_counter and stay
      else
      begin
        r_clk_counter <= r_clk_counter + 1'b1;
        r_state <= START_STATE;
      end
      
    end
    
    
    RECEIVE_STATE:
    begin
      
      // Wait CLKS_PER_BIT
      if (r_clk_counter < CLOCKS_PER_BIT - 1)
      begin
        r_state <= RECEIVE_STATE;
        r_clk_counter <= r_clk_counter + 1'b1;
      end
        
      else
      begin 
        
        // Sample rx and reset r_clk_counter
        r_rx_byte[r_bit_index] <= r_rx_bit;
        r_clk_counter <= 1'b0;
        
        // Check how many bits received
        if (r_bit_index < 'd7)
        begin
          r_bit_index <= r_bit_index + 1'b1;
          r_state <= RECEIVE_STATE;
        end
        
        else
        begin
          r_state <= STOP_STATE;
        end
      
      end
    
    end        
        
    
    STOP_STATE:
    begin
    
      // Wait CLKS_PER_BIT for stop bit to arrive
      if (r_clk_counter < CLOCKS_PER_BIT - 1)
      begin
        r_clk_counter <= r_clk_counter + 1'b1;
        r_state <= STOP_STATE;
      end
      
      // Set data valid and go to cleanup state
      else
      begin
        r_rx_data_valid <= 1'b1;
        r_state <= CLEANUP_STATE;
      end
      
    end
    
    
    CLEANUP_STATE:
    begin
      // Single data valid pulse for higher-level module, then go to idle
      r_rx_data_valid <= 1'b0;
      r_state <= IDLE_STATE;
    end
    
    
    default:
    begin
      r_state <= IDLE_STATE;
    end
    
      
  endcase
end


// Assign output registers to an identical internal register (good practice)

assign o_rx_data_valid = r_rx_data_valid;
assign o_rx_byte = r_rx_byte;

endmodule