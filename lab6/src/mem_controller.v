// Author:    Kagan Dikmen
// Modified:  2024-01-12
// Status:    unknown

module mem_controller #(
  parameter FIFO_WIDTH = 8
) (
  input clk,
  input rst,
  input rx_fifo_empty,
  input tx_fifo_full,
  input [FIFO_WIDTH-1:0] din,

  output rx_fifo_rd_en,
  output tx_fifo_wr_en,
  output [FIFO_WIDTH-1:0] dout,
  output [5:0] state_leds
);

  localparam MEM_WIDTH = 8;   /* Width of each mem entry (word) */
  localparam MEM_DEPTH = 256; /* Number of entries */
  localparam NUM_BYTES_PER_WORD = MEM_WIDTH/8;
  localparam MEM_ADDR_WIDTH = $clog2(MEM_DEPTH); 

  reg [NUM_BYTES_PER_WORD-1:0] mem_we = 0;
  reg [MEM_ADDR_WIDTH-1:0] mem_addr;
  reg [MEM_WIDTH-1:0] mem_din;
  wire [MEM_WIDTH-1:0] mem_dout;

  memory #(
    .MEM_WIDTH(MEM_WIDTH),
    .DEPTH(MEM_DEPTH)
  ) mem(
    .clk(clk),
    .en(1'b1),
    .we(mem_we),
    .addr(mem_addr),
    .din(mem_din),
    .dout(mem_dout)
  );

  localparam 
    IDLE = 3'd0,
    READ_CMD = 3'd1,
    READ_ADDR = 3'd2,
    READ_DATA = 3'd3,
    READ_MEM_VAL = 3'd4,
    ECHO_VAL = 3'd5,
    WRITE_MEM_VAL = 3'd6;

  reg [2:0] curr_state;
  reg [2:0] next_state;

  reg state_complete;

  always @(posedge clk) begin

    /* state reg update */
    if (rst)
    begin
      curr_state <= IDLE;
      cmd <= 'b0;
      addr <= 'b0;
      data <= 'b0;
      mem_we <= 'b0;
      mem_addr <= 'b0;
      mem_din <= 'b0;
    end
    else if (state_complete == 1'b1)
    begin
      curr_state <= next_state;
    end
    else
    begin
      curr_state <= curr_state;
    end

  end

  // reg [2:0] pkt_rd_cnt;
  reg [MEM_WIDTH-1:0] cmd;
  reg [MEM_WIDTH-1:0] addr;
  reg [MEM_WIDTH-1:0] data;
  // reg handshake;


  reg rx_fifo_rd_en_b;
  reg tx_fifo_wr_en_b;
  reg [FIFO_WIDTH-1:0] dout_b;
  reg [5:0] state_leds_b;

  
  always @(*) begin
    
    /* initial values to avoid latch synthesis */
    next_state <= IDLE;

    case (curr_state)

      IDLE:           next_state <= READ_CMD;
      READ_CMD:       next_state <= READ_ADDR;
      READ_ADDR:      next_state <= (din == 'd48) ? READ_MEM_VAL : READ_DATA;
      READ_DATA:      next_state <= WRITE_MEM_VAL;
      READ_MEM_VAL:   next_state <= ECHO_VAL;
      // ECHO_VAL:       next_state <= IDLE;
      // WRITE_MEM_VAL:  next_state <= IDLE;

    endcase

  end

  always @(*) begin
    
    /* initial values to avoid latch synthesis */
    rx_fifo_rd_en_b <= 1'b0;
    tx_fifo_wr_en_b <= 1'b0; 
    dout_b <= 'b0;
    state_leds_b <= 'b0;
    state_complete <= 1'b0;
    
    case (curr_state)

      /* output and mem signal logic */
      
      IDLE:     // 0
      begin
        mem_we <= 1'b0;
        if (!rx_fifo_empty)
        begin
          state_complete <= 1'b1;
        end
      end
      
      READ_CMD:         // 1
      begin
        if (!rx_fifo_empty)
        begin
          rx_fifo_rd_en_b <= 1'b1;
          state_complete <= 1'b1;
        end
      end
      
      READ_ADDR:        // 2
      begin
        if (!rx_fifo_empty)
        begin
          cmd <= din;
          rx_fifo_rd_en_b <= 1'b1;
          state_complete <= 1'b1;
        end
      end
    
      READ_DATA:        // 3
      begin
        if (!rx_fifo_empty)
        begin
          addr <= din; 
          rx_fifo_rd_en_b <= 1'b1;
          state_complete <= 1'b1;
        end
      end
      
      READ_MEM_VAL:     // 4
      begin
        addr <= din;
        mem_addr <= din;
        state_complete <= 1'b1;
      end
      
      ECHO_VAL:         // 5
      begin
        data <= mem_dout;
        tx_fifo_wr_en_b <= 1'b1;
        dout_b <= mem_dout;
        state_complete <= 1'b1;
      end
      
      WRITE_MEM_VAL:    // 6
      begin
        data <= din;
        mem_we <= 1'b1;
        mem_addr <= addr;
        mem_din <= din;
        state_complete <= 1'b1;
      end
      
      default: 
      begin
        $error("ERROR: default state at %t ns", $realtime/1000);
      end
      
    endcase

  end


  always @(posedge clk) begin

    /* byte reading and packet counting */

  end

  /* TODO: MODIFY THIS */
  assign state_leds = 'd0;

  assign rx_fifo_rd_en = rx_fifo_rd_en_b;
  assign tx_fifo_wr_en = 'd0;
  assign dout = 'd0;

endmodule
