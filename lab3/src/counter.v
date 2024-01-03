// Modified:    2024-01-03
// Status:      works fine

module counter #(
    parameter CYCLES_PER_SECOND = 125_000_000
)(
    input clk,
    input [3:0] buttons,
    output [3:0] leds
);
    reg [3:0] counter = 0;
    assign leds = counter;

    reg [26:0] cts_upto_cycpersec = 'b0;

    always @(posedge clk) begin
        
        cts_upto_cycpersec <= 'b0;
        if (buttons[0])
            counter <= counter + 4'd1;
        else if (buttons[1])
            counter <= counter - 4'd1;
        else if (buttons[3])
            counter <= 4'd0;
        else if (buttons[2])
        begin
            cts_upto_cycpersec <= (cts_upto_cycpersec == CYCLES_PER_SECOND-1) ? 'b0 : cts_upto_cycpersec + 'b1;
            counter <= (cts_upto_cycpersec == CYCLES_PER_SECOND-1) ? counter + 'b1 : counter;
        end   
        else
            counter <= counter;
    end
endmodule

