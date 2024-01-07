// Author:      Kagan Dikmen
// Modified:    2024-01-07
// Status:      works fine

module dac #(
    parameter CYCLES_PER_WINDOW = 1024,
    parameter CODE_WIDTH = $clog2(CYCLES_PER_WINDOW)
)(
    input clk,
    input rst,
    input [CODE_WIDTH-1:0] code,
    output next_sample,
    output reg pwm
);

    reg [CODE_WIDTH-1:0] ctr;
    // reg pwm_buffer = 'b0;
    reg next_sample_buffer;


    always @(posedge clk)
    begin

        if (rst)
        begin
            ctr = 'b0;
            pwm = 'b0;
            next_sample_buffer = 'b0;
        end
        
        //ctr = (ctr == CYCLES_PER_WINDOW-1) ? 'b0 : ctr + 1;

        else if (ctr == CYCLES_PER_WINDOW-1)
        begin
            next_sample_buffer = 1'b0;
            ctr = 1'b0;
        end
        else if (ctr == CYCLES_PER_WINDOW-2)
        begin
            next_sample_buffer = 1'b1;
            ctr = ctr + 1;
        end
        else
        begin
            next_sample_buffer = 1'b0;
            ctr = ctr + 1;
        end

    end

    always @(ctr)
    begin
        if (code == 'b0)
        begin
            pwm = 1'b0;
        end
        else if(ctr <= code)
        begin
            pwm = 1'b1;
        end
        else
        begin
            pwm = 1'b0;
        end
    end

    // assign pwm = pwm_buffer;
    //assign pwm = 0;
    assign next_sample = next_sample_buffer;
    
endmodule
