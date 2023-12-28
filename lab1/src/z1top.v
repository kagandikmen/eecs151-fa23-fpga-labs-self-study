module z1top(
  input CLK_125MHZ_FPGA,
  input [3:0] BUTTONS,
  input [1:0] SWITCHES,
  output [5:0] LEDS
);

  wire a, b, c, d;

  and(a, BUTTONS[1], BUTTONS[0]);
  and(b, BUTTONS[2], a);
  and(c, BUTTONS[3], b);
  and(d, BUTTONS[4], c);
  and(LEDS[1], BUTTONS[5], d);
  assign LEDS[5:2] = 0;
  assign LEDS[0] = 0;
endmodule
