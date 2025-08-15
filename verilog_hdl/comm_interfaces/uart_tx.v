module uart_tx #(parameter CLOCKS_PER_BIT = 1302)
(

  // Inputs
  input i_clk,
  input [7:0]   i_tx_data,
  input         i_tx_data_valid,  // PULSE indicating data is ready
  
  // Outputs
  output reg    o_tx_active,
  output reg    o_tx_done,
  output reg    o_tx_bit  // Declare a register here, no assignment in always block
);


// State definitions
localparam IDLE_STATE      = 3'b000;
localparam START_STATE     = 3'b001;
localparam TRANSMIT_STATE  = 3'b010;
localparam STOP_STATE      = 3'b011;
localparam CLEANUP_STATE     = 3'b100;

// Internal Registers
reg [10:0]  r_clk_counter;
reg [2:0]   r_bit_index;
reg [2:0]   r_state;
reg [7:0]   r_tx_data;


// State Transition Logic
/*
Data bits are transmitted immediately upon new state entry
*/
always @(posedge i_clk)
 begin
    
   case (r_state)
      
      
      IDLE_STATE:
      begin  
        
        // Initialize signals
        o_tx_bit <= 1'b1; // Hold high until start bit
        o_tx_done <= 1'b0;
        r_clk_counter <= 0;
        r_bit_index <= 0;
        
        // Transition to START_STATE when data valid goes high
        if (i_tx_data_valid == 1)
        begin
          o_tx_active <= 1'b1;
          r_tx_data <= i_tx_data;
          r_state <= START_STATE;
        end
      end
      
      
      START_STATE:
      begin 
        o_tx_bit <= 1'b0;  // Send start bit   
        
        // Wait CLOCKS_PER_BIT and stay here
        if (r_clk_counter < CLOCKS_PER_BIT - 1)
        begin
          r_clk_counter <= r_clk_counter + 1;
          r_state <= START_STATE;
        end
        
        // After CLOCKS_PER_BIT, reset counter and go to TRANSMIT_STATE
        else
        begin
          r_clk_counter <= 0;
          r_state <= TRANSMIT_STATE;
        end
      
      end
        
      
      TRANSMIT_STATE:
      begin 
        
        // Transmit next data bit
        o_tx_bit <= r_tx_data[r_bit_index];

        // Wait CLOCKS_PER_BIT and stay here
        if (r_clk_counter < CLOCKS_PER_BIT - 1)
        begin
          r_clk_counter <= r_clk_counter + 1;
          r_state <= TRANSMIT_STATE;
        end
        
        // After CLOCKS_PER_BIT, reset counter and evaluate bit index
        else
        begin
          r_clk_counter <= 0;
          
          // If not last bit, increment bit index and stay here
          if (r_bit_index < 7)
          begin
            r_bit_index <= r_bit_index + 1;
            r_state <= TRANSMIT_STATE;
          end
          
          // If last bit, reset index, go to STOP_STATE
          else
          begin
            r_bit_index <= 0;
            r_state <= STOP_STATE;
          end
        end
      
      end
            
      
      STOP_STATE:
      begin 
        
        // Send the stop bit
        o_tx_bit <= 1'b1;
        
        // Wait CLOCKS_PER_BIT and stay here
        if (r_clk_counter < CLOCKS_PER_BIT - 1)
        begin
          r_clk_counter <= r_clk_counter + 1;
          r_state <= STOP_STATE;
        end
        
        // After CLOCKS_PER_BIT, reset counter, set handshake signals, and go to CLEANNUP_STATE
        else
        begin
          o_tx_done <= 1'b1;
          o_tx_active <= 1'b0;
          r_clk_counter <= 0;
          r_state <= CLEANUP_STATE;
        end
      
      end  
    
      
      CLEANUP_STATE:
      begin
        
        // Stay here only one cycle
        o_tx_done <= 1'b1;
        r_state <= IDLE_STATE;
        
      end
    
      default:
      begin
        
        r_state <= IDLE_STATE;
        
      end
      
    
    endcase
  
  end

  
endmodule