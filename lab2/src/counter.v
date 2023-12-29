// Modified:    2023-12-29
// Status:      works fine

`define CLK_PER_SECOND 125000000   // See line 15
// `define CLK_PER_SECOND 125000      // for tests


module counter (
  input clk,
  input ce,
  output [3:0] LEDS
);
    // TODO: delete this assignment once you write your own logic.
    // assign LEDS = 4'd0;

    // TODO: Instantiate a reg net to count the number of cycles
    // required to reach one second. Note that our clock period is 8ns.
    // Think about how many bits are needed for your reg.

        // 1s/8ns = 125,000,000
        // log_2(125,000,000) = 26,90
        // So we need 27 bits.

  reg [26:0] clk_counter = 27'b0;

    // TODO: Instantiate a reg net to hold the current count,
    // and assign this value to the LEDS.

  reg [3:0] sec_count = 4'b0;
  assign LEDS[3] = sec_count[3];
  assign LEDS[2] = sec_count[2];
  assign LEDS[1] = sec_count[1];
  assign LEDS[0] = sec_count[0];

    // TODO: update the reg if clock is enabled (ce is 1).
    // Once the requisite number of cycles is reached, increment the count.

  always @(posedge clk)
  begin
    
    if (ce == 1)
    begin
      clk_counter = clk_counter + 1;
    end

  // end

  // always @(posedge clk)
  // begin
    
    if (clk_counter == `CLK_PER_SECOND)
    begin
      clk_counter = 0;
      sec_count = sec_count + 1;
    end

  end

endmodule

