// Author:      Kagan Dikmen
// Created:     2024-01-03
// Modified:    2024-01-03
// Status:      works fine

`define CYCLES_PER_SECOND 125_000_000

`include "../src/counter.v"

`timescale 1ns/1ps

module counter_tb ();

    reg clk_tb = 0;
    always #(5) clk_tb <= ~clk_tb;

    reg [3:0] buttons_tb;
    wire [3:0] leds_tb;

    counter #(.CYCLES_PER_SECOND(`CYCLES_PER_SECOND)) 
            ctr 
            (
            .clk        (clk_tb), 
            .buttons    (buttons_tb), 
            .leds       (leds_tb)
            );


    initial
    begin: test
        
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, counter_tb);

        buttons_tb <= 4'b0;
        repeat (5) @(posedge clk_tb);

        buttons_tb[0] <= 'b1;
        repeat (5) @(posedge clk_tb);

        buttons_tb[0] <= 'b0;
        buttons_tb[1] <= 'b1;
        repeat (4) @(posedge clk_tb);

        buttons_tb[1] <= 'b0;
        buttons_tb[0] <= 'b1;
        repeat (4) @(posedge clk_tb);

        buttons_tb[0] <= 'b0;
        buttons_tb[3] <= 'b1;
        repeat (5) @(posedge clk_tb);

        buttons_tb[3] <= 'b0;
        buttons_tb[0] <= 'b1;
        repeat (10) @(posedge clk_tb);

        buttons_tb[0] <= 'b0;
        buttons_tb[2] <= 'b1;
        repeat (2) @(posedge clk_tb);

        buttons_tb[2] <= 'b0;
        buttons_tb[0] <= 'b1;
        repeat (10) @(posedge clk_tb);

        buttons_tb <= 4'b0;
        repeat (1000) @(posedge clk_tb);

        buttons_tb[3] <= 'b1;
        repeat (2) @(posedge clk_tb);

        buttons_tb[3] <= 'b0;
        buttons_tb[2] <= 'b1;
        repeat (17 * `CYCLES_PER_SECOND) @(posedge clk_tb);

        buttons_tb <= 4'b0;
        repeat (1000) @(posedge clk_tb);

        $finish();

    end

endmodule