module z1top(
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS
);

  wire a, b;

  and(a, BUTTONS[1], BUTTONS[0]);
  and(b, BUTTONS[2], a);
  and(LEDS[1], BUTTONS[3], b);
  assign LEDS[5:2] = 0;
  assign LEDS[0] = 0;
endmodule
