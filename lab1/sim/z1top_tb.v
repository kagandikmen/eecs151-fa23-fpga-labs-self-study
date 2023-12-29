// Author:      Kagan Dikmen
// Created:     2023-12-28
// Modified:    2023-12-28
// Status:      works fine

// This is a testbench for the z1top module
// (I am yet to acquire an FPGA board, so I had to test my answer in Vivado)

`timescale 1ns/1ns

module z1top_tb();

reg CLK_125MHZ_FPGA;
reg [3:0] BUTTONS;
reg [1:0] SWITCHES;
wire [5:0] LEDS;

z1top dut(.CLK_125MHZ_FPGA(CLK_125MHZ_FPGA), 
            .BUTTONS(BUTTONS), 
            .SWITCHES(SWITCHES),
            .LEDS(LEDS) );

initial begin
    BUTTONS[3] = 0; BUTTONS[2] = 0; BUTTONS[1] = 0; BUTTONS[0] = 0;     #10;
    BUTTONS[3] = 1; BUTTONS[2] = 1; BUTTONS[1] = 1; BUTTONS[0] = 0;     #20;
    BUTTONS[3] = 1; BUTTONS[2] = 1; BUTTONS[1] = 1; BUTTONS[0] = 1;     #30;
    BUTTONS[3] = 1; BUTTONS[2] = 1; BUTTONS[1] = 0; BUTTONS[0] = 1;     #40;
end

endmodule