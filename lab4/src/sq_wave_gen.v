// Author:      Kagan Dikmen
// Modified:    2024-01-07
// Status:      works fine

`include "../src/dac.v"

`define CLOCKS_PER_SECOND 125000000

module sq_wave_gen #(
    parameter STEP = 10
)(
    input clk,
    input rst,
    input next_sample,
    input [2:0] buttons,
    output [9:0] code,
    output [3:0] leds
);

    dac dac_1   (.clk(clk),
                .rst(rst),
                .code(code),
                .next_sample(next_sample),
                .pwm());

    reg [26:0] ctr;
    reg [9:0] code_buffer;
    reg [4:0] leds_buffer;
    reg [50:0] sample_threshold;
    reg current_mode;
        
        
    always @(posedge clk)
    begin
        
        if (rst)
        begin
            ctr = 'b0;
            code_buffer = 'b0;
            leds_buffer = 4'b0;
            sample_threshold = 14'd139;     // default sample threshold: 139 samples
            current_mode = 1'b0;            // default mode: linear

            // leds[0] = 0 for linear and = 1 for exponential

        end
        else
        begin
            ctr = (ctr == sample_threshold * 1024 * 2 - 1) ? 'b0 : ctr + 1;      
        end      
    end


    always @(posedge buttons[0])        // decrease the period
    begin
        ctr = 'b0;
        if (current_mode == 1'b0)       // linear mode
        begin
            sample_threshold = sample_threshold - STEP;
        end
        else                            // exponential mode
        begin
            sample_threshold = sample_threshold >> 1;
        end
    end


    always @(posedge buttons[1])        // increase the period
    begin
        ctr = 'b0;
        if (current_mode == 1'b0)       // linear mode
        begin
            sample_threshold = sample_threshold + STEP;
        end
        else                            // exponential mode
        begin
            sample_threshold = sample_threshold << 1;
        end
    end


    always @(posedge buttons[2])        // switching between modes
    begin
        ctr = 'b0;
        current_mode = ~current_mode;
    end


    always @(ctr)
    begin
        if (ctr <= sample_threshold * 1024)
        begin
            code_buffer = 'd562;
        end
        else if (ctr <= sample_threshold * 1024 * 2)
        begin
            code_buffer = 'd462;
        end
        else
        begin
            code_buffer = 'd0;
        end
    end
    


    /*
    reg [26:0] ctr = 'b0;
    reg [9:0] code_buffer = 'b0;


    always @(posedge clk)
    begin

        ctr = (ctr == `PERIOD-1) ? 'b0 : ctr + 1;

    end

    always @(ctr)
    begin
        
        if(ctr < `PERIOD/2)
        begin
            code_buffer = 'd562;
        end
        else
        begin
            code_buffer = 'd462;
        end

    end
    
    assign code = code_buffer;
    */

    assign leds [3:1] = leds_buffer [3:1];
    assign leds [0] = current_mode;
    assign code = code_buffer;

    //assign code = 0;
    //assign leds = 0;
endmodule
