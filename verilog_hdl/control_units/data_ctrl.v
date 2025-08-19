module data_ctrl (

  // ADC signals
  input               i_clk,
  input               i_trigger_pulse,
  input               i_tx_done,
  input               i_response_valid,
  
  // Tx byte load signals
  output              o_mem_sel,
  output              o_byte_sel,
  
  // Scratch buffer routing signals
  output              o_scratch_wr_en,
  output [9:0]        o_scratch_wr_addr,
  output              o_scratch_rd_en,
  output [9:0]        o_scratch_rd_addr,
  
  // FIFO routing signals
  output              o_FIFO_wr_en,
  output              o_FIFO_rd_en,
  
  // Enable Tx
  output              o_tx_en,

  // Upstream module handshake signals
  output              o_transfer_done,
  
  // Simulation debug probe
  output [2:0]        o_state,
  output [9:0]        o_FIFO_wr_counter,
  output [9:0]        o_FIFO_rd_counter
);

// Memory parameters
parameter MEM_DEPTH     = 1024;



// State definitions
localparam s_IDLE          = 3'b000;
localparam s_SCRATCH       = 3'b001;
localparam s_CAPTURE       = 3'b010;
localparam s_WRITE         = 3'b011;
localparam s_TRANSFER      = 3'b100;
localparam s_LOWER_HALF    = 3'b101;
localparam s_UPPER_HALF    = 3'b110;
localparam s_CLEANUP       = 3'b111;


// Internal wires
wire w_new_sample;
wire w_trigger;
wire w_tx_done;


// Internal Registers
reg [2:0] r_sample_sync            = 0;
reg [2:0] r_trigger_sync           = 0;
reg       r_trigger_latch          = 0;
reg       r_mem_sel                = 0;
reg       r_byte_sel               = 0;
reg       r_tx_en                  = 0;
reg [2:0] r_state             = s_IDLE;
reg [9:0] r_scratch_wr_addr        = 0;
reg [9:0] r_scratch_rd_addr        = 0;
reg       r_scratch_wr_en          = 0;
reg       r_scratch_rd_en          = 0;
reg [9:0] r_FIFO_rd_counter        = 0;
reg [9:0] r_FIFO_wr_counter        = 0;
reg       r_FIFO_rd_en             = 0;
reg       r_FIFO_wr_en             = 0;
reg       r_transfer_done          = 0;


// Input assignments
assign w_tx_done    = i_tx_done;
assign w_new_sample = r_sample_sync[1] & ~r_sample_sync[2];
assign w_trigger    = r_trigger_sync[1] & ~r_trigger_sync[2];


// Output assignments
assign o_mem_sel = r_mem_sel;
assign o_byte_sel = r_byte_sel;
assign o_tx_en = r_tx_en;
assign o_scratch_wr_addr = r_scratch_wr_addr;
assign o_scratch_rd_addr = r_scratch_rd_addr;
assign o_scratch_wr_en = r_scratch_wr_en;
assign o_scratch_rd_en = r_scratch_rd_en;
assign o_FIFO_wr_en = r_FIFO_wr_en;
assign o_FIFO_rd_en = r_FIFO_rd_en;
assign o_transfer_done = r_transfer_done;

// Simulation debug probe
assign o_state = r_state;
assign o_FIFO_wr_counter = r_FIFO_wr_counter;
assign o_FIFO_rd_counter = r_FIFO_rd_counter;


always @(posedge i_clk)
begin

  // Pulse sync for asynchronous input signals
  r_sample_sync[0] <= i_response_valid;
  r_sample_sync[1] <= r_sample_sync[0];
  r_sample_sync[2] <= r_sample_sync[1];
  
  r_trigger_sync[0] <= i_trigger_pulse;
  r_trigger_sync[1] <= r_trigger_sync[0];
  r_trigger_sync[2] <= r_trigger_sync[1];

  
  // Latch trigger pulse
  if (w_trigger == 1)
  begin
    
    r_trigger_latch <= 1;
    
  end
  
  else
  begin
  
    if (r_transfer_done == 1)
    begin
    
      r_trigger_latch <= 0;
    
    end
  
  end
  
  case (r_state)
  
    
    s_IDLE:
    begin
      
      if (w_new_sample == 1)
      begin
        
        
        if (r_trigger_latch == 1)
        begin
        
          r_mem_sel <= 1;
          r_state <= s_CAPTURE;
          
        end
        
        else
        begin
          
          r_scratch_wr_en <= 1;
          r_state <= s_SCRATCH;
          
        end
      
      end
      
      else
      begin
      
        r_state <= s_IDLE;
      
      end
        
      
    end
    
    
    s_SCRATCH:
    begin
    
      r_scratch_wr_en <= 0;
      r_scratch_wr_addr <= r_scratch_wr_addr + 1;
      r_state <= s_IDLE;
      
    end
    
    
    s_CAPTURE:
    begin
      
      
      if (w_new_sample == 1)
      begin
      
      
        if (r_FIFO_wr_counter < MEM_DEPTH - 1)
        begin
          
          r_FIFO_wr_en <= 1;
          r_state <= s_WRITE;
          
        end
      
        else
        begin
          
          r_scratch_rd_addr <= r_scratch_wr_addr + 1;
          r_state <= s_TRANSFER;
          
        end
      
      end
      
      else
      begin
      
        r_state <= s_CAPTURE;
        
      end
      
    
    end
    
    
    s_WRITE:
    begin
      
      r_FIFO_wr_en <= 0;
      r_FIFO_wr_counter <= r_FIFO_wr_counter + 1;
      r_state <= s_CAPTURE;
      
    end
    
    
    s_TRANSFER:
    begin
      
      if (r_mem_sel == 0)
      begin
      
        if (r_scratch_rd_addr == r_scratch_wr_addr)
        begin
          
          r_mem_sel <= 1;
          r_state <= s_TRANSFER;
          
        end
        
        else
        begin
          
          r_tx_en <= 1;
          r_scratch_rd_en <= 1;
          r_state <= s_LOWER_HALF;
        
        end
      
      end
    
    
      else
      begin
      
        if (r_FIFO_rd_counter < MEM_DEPTH - 1)
        begin
          
          r_tx_en <= 1;
          r_FIFO_rd_en <= 1;
          r_state <= s_LOWER_HALF;
          
        end
        
        else
        begin
          
          r_transfer_done <= 1;
          r_state <= s_CLEANUP;
        
        end
      
      end
    
    end
      
      
      s_LOWER_HALF:
      begin
        
        if (w_tx_done == 0)
        begin
        
          r_tx_en <= 0;
          r_state <= s_LOWER_HALF;
        
        end
        
        else
        begin
        
          r_byte_sel <= 1;
          r_tx_en <= 1;
          r_state <= s_UPPER_HALF;
        
        end
        
        
      end
      
      
      s_UPPER_HALF:
      begin
        
        if (w_tx_done == 0)
        begin
        
          r_tx_en <= 0;
          r_FIFO_rd_en <= 0;
          r_scratch_rd_en <= 0;
          r_state <= s_UPPER_HALF;
        
        end
        
        else
        begin
          
          if (r_mem_sel == 1)
          begin
          
            r_FIFO_rd_counter <= r_FIFO_rd_counter + 1;
   
          end
          
          else 
          begin
          
            r_scratch_rd_addr <= r_scratch_rd_addr + 1;
          
          end
          
          r_byte_sel <= 0;
          r_state <= s_TRANSFER;
              
        end
        
      end
      
      
      s_CLEANUP:
      begin
      
        r_mem_sel           <=          0;
        r_byte_sel          <=          0;
        r_tx_en             <=          0;
        r_scratch_wr_addr   <=      10'b0;
        r_scratch_rd_addr   <=      10'b0;
        r_scratch_wr_en     <=          0;
        r_scratch_rd_en     <=          0;
        r_FIFO_rd_counter   <=      10'b0;
        r_FIFO_wr_counter   <=      10'b0;
        r_FIFO_rd_en        <=          0;
        r_FIFO_wr_en        <=          0;
        r_transfer_done     <=          0;
        r_state             <=     s_IDLE;
      
      end
      
      
      
      
      
    endcase
    
    
    

end




endmodule