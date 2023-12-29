// Modified:    2023-12-29
// Status:      works fine

`timescale 1ns/1ns
`include "../src/counter.v"
`define SECOND 1000000000
`define MS 1000000

module counter_testbench();
    reg clock = 0;
    reg ce;
    wire [3:0] LEDS;

    counter ctr (
        .clk(clock),
        .ce(ce),
        .LEDS(LEDS)
    );

    // Notice that this code causes the `clock` signal to constantly
    // switch up and down every 4 time steps.
    always #(4) clock <= ~clock;

    initial begin
        
        // commented out the conditional part because it was causing an error
        // (I use my own machine, not the lab machines of Berkeley)
        //`ifdef IVERILOG
            $dumpfile("counter_testbench.vcd");
            $dumpvars(0, counter_testbench);
        //`endif
        // `ifndef IVERILOG
        //     $vcdpluson;
        // `endif
        

        // TODO: Change input values and step forward in time to test
        // your counter and its clock enable/disable functionality.
        
        ce = 1;
        repeat (250000) @(posedge clock);
        #(1000);
        repeat (250000) @(posedge clock);
        ce = 0;
        repeat (250000) @(posedge clock);
        ce = 1;
        repeat (5000000) @(posedge clock);
        ce = 0;

        // VSC command, commented out

        // `ifndef IVERILOG
        //     $vcdplusoff;
        // `endif
        
        $finish();
    end
endmodule

