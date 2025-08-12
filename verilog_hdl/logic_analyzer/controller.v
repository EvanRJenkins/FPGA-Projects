module controller(
  
  //Module Inputs
  input wire           i_clk,
  input wire           i_sample_clk,
  input wire           i_tx_ready,
  input wire [11:0]    i_sample_data,

  //Module Outputs
  output reg [11:0]    o_write_data,
  output reg [8:0]     o_write_address,
  output reg           o_write_en,
  output reg           o_tx_en

);

// State definitions
localparam IDLE_STATE      = 2'b00;
localparam ACTIVE_STATE    = 2'b01;
localparam TRANSFER_STATE  = 2'b10;
localparam DONE_STATE      = 2'b11;

// Internal Registers
reg [1:0] r_last_state;
reg [1:0] r_next_state;
reg [11:0] r_sample_latch;


always @(posedge i_clk)
  begin
  end



endmodule
