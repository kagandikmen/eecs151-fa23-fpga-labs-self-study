// Modified:    2023-12-31
// Status:      works fine

module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output [WIDTH-1:0] sync_signal
);
    // TODO: Create your 2 flip-flop synchronizer here
    // This module takes in a vector of WIDTH-bit asynchronous
    // (from different clock domain or not clocked, such as button press) signals
    // and should output a vector of WIDTH-bit synchronous signals
    // that are synchronized to the input clk

    reg [WIDTH-1 : 0] between_ffs = 'b0;
    reg [WIDTH-1 : 0] after_ffs = 'b0;

    always @(posedge clk)
    begin
        between_ffs <= async_signal;
        after_ffs <= between_ffs;
    end

    assign sync_signal = after_ffs;
    

    // Remove this line once you create your synchronizer
    // assign sync_signal = 0;
endmodule
