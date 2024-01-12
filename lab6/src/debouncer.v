// Modified:    2024-01-03
// Status:      works fine

`include "../src/synchronizer.v"

module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal
);
    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required, one saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    integer i, j;

    reg [15:0] wc_max_counter = 16'b0;              // counts up to SAMPLE_CNT_MAX
    reg spg_out = 1'b0;                             // output of sample pulse generator

    wire [WIDTH-1:0] synch_out_signal;        // glitchy but synchronized

    reg [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0];

    reg [WIDTH-1:0] debouncer_out_tmp = 'b0;        // buffer before debouncer output

    // synchronizer instantiation from synchronizer.v
    synchronizer #(.WIDTH(WIDTH)) syn_1 (.async_signal(glitchy_signal),
                                            .clk(clk),
                                            .sync_signal(synch_out_signal));

    always @(posedge clk)
    begin
        wc_max_counter <= (wc_max_counter != SAMPLE_CNT_MAX-1) ? wc_max_counter + 1 : 16'b0;
        spg_out = (wc_max_counter == SAMPLE_CNT_MAX-1) ? 1'b1 : 1'b0;
    end


    genvar in;

    for(in = 0; in<WIDTH; in = in + 1)
    begin
        always @(synch_out_signal[in])
        begin
            saturating_counter[in]= 'b0;
        end
    end


    always @(posedge spg_out)
    begin
        
        for(j = 0; j<WIDTH; j = j + 1)      // j is the actual "button" we are iterating over
        begin
            
            saturating_counter[j] = (saturating_counter[j] == PULSE_CNT_MAX) ? saturating_counter[j] : saturating_counter[j]+1;
            if (synch_out_signal[j] == 'b0)
            begin
                debouncer_out_tmp[j] = 'b0;
            end
            else if (saturating_counter[j] == PULSE_CNT_MAX)
            begin
                debouncer_out_tmp[j] = synch_out_signal[j]; 
            end
           
        end    

    end

    assign debounced_signal = debouncer_out_tmp;

    // Remove this line once you have created your debouncer
    // assign debounced_signal = 0;
    
endmodule
