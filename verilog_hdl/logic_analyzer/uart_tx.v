module uart_tx (

  // Inputs
  input wire i_clk,
  input wire [7:0] i_data_byte,
  input wire i_data_valid,
  
  // Outputs
  output reg o_active,
  output reg o_done,
  output reg o_tx  // Held high by default because start bit is logic LOW
);

// Constants for UART protocol
localparam BYTE_SIZE     = 'd7;
localparam CLKS_PER_BIT  = 'd15;  // (921.6 kHz / 57600 BAUD)

// State definitions
localparam IDLE_STATE      = 2'b00;
localparam START_STATE     = 2'b01;
localparam SEND_BIT_STATE  = 2'b10;
localparam STOP_STATE      = 2'b11;

// Internal Registers
reg [1:0] r_last_state;
reg [1:0] r_next_state;
reg [2:0] r_bit_index;
reg [3:0] r_clk_counter;
reg [7:0] r_data_byte_latch;

// Initial values
initial
  begin
    o_active  = 'b0;
    o_done    = 'b0;
    o_tx      = 'b1;
    r_last_state     = IDLE_STATE;
    r_next_state     = IDLE_STATE;
    r_bit_index      = 3'b000;
    r_clk_counter    = 4'b0000;
  end

// State Transition Logic
/*
Data bits are transmitted immediately upon new state entry
*/
always @(posedge i_clk)
  begin
    
    case (r_next_state)
      
      IDLE_STATE:
        begin  
          o_active <= 'b0;
          r_clk_counter <= 'b0;
          r_bit_index <= 'b0;
          if (r_last_state == STOP_STATE)
            begin
              o_done <= 'b1;
            end
          if (i_data_valid)
            begin
              r_data_byte_latch <= i_data_byte;
              r_last_state <= r_next_state;
              r_next_state <= START_STATE;
            end
        end
      
      START_STATE:
        begin 
          o_active <= 'b1;
          o_done <= 'b0;
          if (r_clk_counter == 'b0)
            begin
              o_tx <= 'b0;  // Send start bit
              r_clk_counter <= r_clk_counter + 'b1;
            end
          else
            begin
              if (r_clk_counter < CLKS_PER_BIT)  // Wait CLKS_PER_BIT before changing states
                begin
                  r_clk_counter <= r_clk_counter + 'b1;
                end
              else
                begin
                  r_clk_counter <= 'b0;
                  r_last_state <= r_next_state;
                  r_next_state <= SEND_BIT_STATE;
                end
            end
        end
        
      SEND_BIT_STATE:
        begin 
          if (r_bit_index < BYTE_SIZE)
            begin
              if (r_clk_counter == 'b0)
                begin
                  o_tx <= r_data_byte_latch[r_bit_index];    // Transmit next data bit
                  r_clk_counter <= r_clk_counter + 'b1;        // Increment clk counter
                end
              else
                if (r_clk_counter < CLKS_PER_BIT)
                  begin
                    r_clk_counter <= r_clk_counter + 'b1;
                  end
                else
                  begin
                    r_clk_counter <= 'b0;
                    r_bit_index <= r_bit_index + 'b1;          // Increment bit index
                  end
            end
          else
            begin
              if (r_clk_counter == 'b0)
                begin
                  r_last_state <= r_next_state;
                  r_next_state <= STOP_STATE;
                end
              else
                if (r_clk_counter < CLKS_PER_BIT)
                  begin
                    r_clk_counter <= r_clk_counter + 'b1;
                  end
                else
                  begin
                    r_clk_counter <= 'b0;
                  end
            end
        end
            
      STOP_STATE:
        begin  
          if (r_clk_counter == 'b0)
            begin
              o_tx <= 'b1;  // Send stop bit
              r_clk_counter <= r_clk_counter + 'b1;
            end
          else
            begin
              if (r_clk_counter < CLKS_PER_BIT)
                begin
                  r_clk_counter <= r_clk_counter + 'b1;
                end
              else
                begin
                  r_clk_counter <= 'b0;
                  r_last_state <= r_next_state;
                  r_next_state <= IDLE_STATE;
                end
            end
        end  
    
    endcase
  
  end

endmodule