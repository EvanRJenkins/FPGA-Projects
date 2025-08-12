module controller(
  
  //Module Inputs
  input wire           i_clk,
  input wire           i_sample_clk,
  input wire           i_tx_ready,
  input wire [11:0]    i_sample_data,
  input wire           i_capture_cmd,

  //Module Outputs
  output reg [11:0]    o_write_data,
  output reg [8:0]     o_write_address,
  output reg           o_write_en,
  output reg           o_tx_en

);

// State definitions
localparam IDLE_STATE       = 2'b00;
localparam CAPTURE_STATE    = 2'b01;
localparam TRANSFER_STATE   = 2'b10;
localparam DONE_STATE       = 2'b11;

// Internal Registers
reg        r_new_sample;
reg [1:0]  r_last_state;
reg [1:0]  r_next_state;
reg [11:0] r_sample_latch;

always @(posedge i_sample_clk)
  begin
    r_sample_latch <= i_sample_data;
    r_new_sample <= 1'b1;
  end

  
always @(posedge i_clk)
  begin
    
    case (r_next_state):

      IDLE_STATE:
        begin
          if (r_last_state == DONE_STATE)
            begin
              // Reset everything
            end
          if (i_capture_cmd)
            begin
              r_next_state <= CAPTURE_STATE;
            end
        end

      CAPTURE_STATE:
        begin
          if (r_new_sample == 1)
            begin
              if (o_write_address < 
              o_write_data <= r_sample_latch;
              o_write_address <= o_write_address + 'b1;
              r_new_sample <= 1'b0;
              
            end
        end

      TRANSFER_STATE:
        begin
        end

      DONE_STATE:
        begin
        end

    endcase
  end



endmodule


