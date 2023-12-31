// Modified:    2023-12-31
// Status:      works fine

module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge

    integer i;

    reg [WIDTH-1 : 0] signal_in_old_value, edp_buffer;

    always @(posedge clk)
    begin
        signal_in_old_value <= signal_in;

        for (i = 0; i < WIDTH; i = i + 1)
        begin
            edp_buffer[i] = 0;
            if ((signal_in_old_value[i] == 1'b0) && (signal_in[i] == 1'b1))
            begin
                edp_buffer[i] = 1;
            end
        end

    end

    // Remove this line once you create your edge detector
    assign edge_detect_pulse = edp_buffer;
endmodule
