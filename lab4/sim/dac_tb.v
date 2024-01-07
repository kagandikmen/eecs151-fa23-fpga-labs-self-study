// Modified:    2024-01-07
// Status:      works fine

`timescale 1ns/1ns
`define CLK_PERIOD 8

`include "../src/dac.v"

module dac_tb();
    // Generate 125 Mhz clock
    reg clk = 0;
    always #(`CLK_PERIOD/2) clk = ~clk;

    // I/O
    reg [2:0] code;
    wire pwm, next_sample;
    reg rst;

    dac #(.CYCLES_PER_WINDOW(8)) DUT (
        .clk(clk),
        .rst(rst),
        .code(code),
        .pwm(pwm),
        .next_sample(next_sample)
    );

    initial begin
        // `ifdef IVERILOG
            $dumpfile("dac_tb.vcd");
            $dumpvars(0, dac_tb);
        // `endif
        // `ifndef IVERILOG
        //     $vcdpluson;
        // `endif

        rst = 1;
        @(posedge clk); #1;
        rst = 0;

        fork
            // Thread to drive code and check output
            begin
                code = 0;
                @(posedge clk); #1;
                repeat (7) begin
                    if (pwm != 0) $error("pwm should be 0 when code is 0");
                    @(posedge clk); #1;
                end
                if (pwm != 0) $error("pwm should be 0 when code is 0");

                code = 7;
                @(posedge clk); #1;
                repeat (7) begin
                    if (pwm != 1) $error("pwm should be 1 when code is 7");
                    @(posedge clk); #1;
                end
                if (pwm != 1) $error("pwm should be 1 when code is 7");

                repeat (2) begin
                    code = 3;
                    @(posedge clk); #1;
                    repeat (3) begin
                        if (pwm != 1) $error("pwm should be 1 on first half of code = 3");
                        @(posedge clk); #1;
                    end
                    repeat (4) begin
                        if (pwm != 0) $error("pwm should be 0 on second half of code = 3");
                        @(posedge clk); #1;
                    end
                end
            end
            // Thread to check next_sample
            begin
                repeat (4) begin
                    if (next_sample != 0) $error("next_sample should start at 0");
                    repeat (7) @(posedge clk); #1;
                    if (next_sample != 1) $error("next_sample should become 1 after 7 cycles");
                    @(posedge clk); #1;
                    if (next_sample != 0) $error("next_sample should go back to 0 on the 8th cycle");
                end
            end
        join

        $display("Test finished");

        // `ifndef IVERILOG
        //     $vcdplusoff;
        // `endif
        $finish();
    end
endmodule
