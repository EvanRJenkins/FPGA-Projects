`timescale 1ns/100ps
module pc_comm_tb ();

reg CLOCK_50 = 0;
reg CLOCK_1 = 0;
reg TRIGGER = 0;


wire w_tx_done;
wire w_mem_sel;
wire w_byte_sel;
wire w_scratch_wr_en;
wire [3:0] w_scratch_wr_addr;
wire w_scratch_rd_en;
wire [3:0] w_scratch_rd_addr;
wire w_FIFO_wr_en;
wire w_FIFO_rd_en;
wire w_tx_en;
wire w_transfer_done;
wire [2:0] w_state;
wire [3:0] w_FIFO_wr_counter;
wire [3:0] w_FIFO_rd_counter;
wire [7:0] w_tx_data;
wire w_tx_bit;
wire [2:0] w_tx_state;
wire [2:0] w_bit_index;


// Simulation assignments
assign w_tx_data = 8'hFF;


always #10 CLOCK_50 <= !CLOCK_50;
always #500 CLOCK_1 <= !CLOCK_1;
always #8000 TRIGGER <= !TRIGGER;


initial
begin

  #52000;
  
  $display("Simulation Complete");
  
  $finish;

end


data_ctrl #(.MEM_DEPTH(16), .COUNTER_WIDTH(4)) data_ctrl_inst
(
	.i_clk(CLOCK_50) ,	// input  i_clk_sig
	.i_trigger_pulse(TRIGGER) ,	// input  i_trigger_pulse_sig
	.i_tx_done(w_tx_done) ,	// input  i_tx_done_sig
	.i_response_valid(CLOCK_1) ,	// input  i_response_valid_sig
	.o_mem_sel(w_mem_sel) ,	// output  o_mem_sel_sig
	.o_byte_sel(w_byte_sel) ,	// output  o_byte_sel_sig
	.o_scratch_wr_en(w_scratch_wr_en) ,	// output  o_scratch_wr_en_sig
	.o_scratch_wr_addr(w_scratch_wr_addr) ,	// output [9:0] o_scratch_wr_addr_sig
	.o_scratch_rd_en(w_scratch_rd_en) ,	// output  o_scratch_rd_en_sig
	.o_scratch_rd_addr(w_scratch_rd_addr) ,	// output [9:0] o_scratch_rd_addr_sig
	.o_FIFO_wr_en(w_FIFO_wr_en) ,	// output  o_FIFO_wr_en_sig
	.o_FIFO_rd_en(w_FIFO_rd_en) ,	// output  o_FIFO_rd_en_sig
	.o_tx_en(w_tx_en) ,	// output  o_tx_en_sig
	.o_transfer_done(w_transfer_done) ,	// output  o_transfer_done_sig
	.o_state(w_state) ,	// output [2:0] o_state_sig
	.o_FIFO_wr_counter(w_FIFO_wr_counter) ,	// output [9:0] o_FIFO_wr_counter_sig
	.o_FIFO_rd_counter(w_FIFO_rd_counter) 	// output [9:0] o_FIFO_rd_counter_sig
);


uart_tx #(.CLOCKS_PER_BIT(2))uart_tx_inst
(
	.i_clk(CLOCK_50) ,	// input  i_clk_sig
	.i_tx_data(w_tx_data) ,	// input [7:0] i_tx_data_sig
	.i_tx_data_valid(w_tx_en) ,	// input  i_tx_data_valid_sig
	.o_tx_active() ,	// output  o_tx_active_sig
	.o_tx_done(w_tx_done) ,	// output  o_tx_done_sig
	.o_tx_bit(w_tx_bit) , 	// output  o_tx_bit_sig
  .o_tx_state(w_tx_state) ,
  .o_bit_index(w_bit_index)
  );

  
endmodule
