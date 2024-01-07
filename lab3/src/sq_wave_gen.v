// Author:      Kagan Dikmen
// Modified:    2024-01-07
// Status:      works fine

`define PERIOD 139*1024*2
`include "../src/dac.v"

module sq_wave_gen (
    input clk,
    input next_sample,
    output [9:0] code
);

    dac dac_1   (.clk(clk),
                .code(code),
                .next_sample(next_sample),
                .pwm());


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
endmodule
