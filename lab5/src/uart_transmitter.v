// Author:      Kagan Dikmen
// Modified:    2024-01-10
// Status:      works fine

module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  SAMPLE_TIME         =   SYMBOL_EDGE_TIME / 2;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);

    reg [3:0] bit_counter;
    reg [9:0] bit_sequence;
    reg [10:0] counter;
    reg data_in_ready_buffer;
    reg serial_out_buffer;
    reg working;

    

    assign data_in_ready = data_in_ready_buffer;
    assign serial_out = serial_out_buffer;

    // synchronous reset
    always @(posedge clk)
    begin
        if (reset)
        begin
            bit_counter = 4'b0;
            bit_sequence = 10'b0;
            counter = 11'b0;
            data_in_ready_buffer = 1'b0;
            serial_out_buffer = 1'b1;
            working = 1'b0;
        end
    end

    // counters (counter from 0 upto SYMBOL_EDGE_TIME-1 and bit_counter from 0 upto 10)
    always @(posedge clk)
    begin
        counter = (working && counter == SYMBOL_EDGE_TIME-1) ? 'b0 : (working) ? counter + 1 : counter;
        bit_counter = (working && counter == SYMBOL_EDGE_TIME-1) ? bit_counter + 1 : bit_counter;
    end

    // is the transmitter currently transmitting?
    always @(posedge clk)
    begin
        if (data_in_ready && data_in_valid)
        begin
            bit_counter = 'b0;
            counter = 'b0;
            data_in_ready_buffer = 1'b0;
            working = 1'b1;
        end
        else if (bit_counter == 11)
        begin
            working = 1'b0;
        end
    end

    // implementation of the ready-valid interface
    always @(posedge clk)
    begin
        if (!working)
        begin
            data_in_ready_buffer = 1'b1;
        end
        else
        begin
            serial_out_buffer = (bit_counter == 1) ? 1'b0 :
                                (bit_counter > 1 && bit_counter < 10) ? data_in[bit_counter - 2] : 
                                (bit_counter == 10) ? 1'b1 : 1'b1;
        end
    end


    /*  AN OLD IMPLEMENTATION ATTEMPT

    reg [3:0] bit_counter;
    reg [10:0] counter;
    reg processing;
    reg [9:0] data_sequence;

    wire sampling_moment;

    assign data_in_ready = ~processing;

    assign sampling_moment = (counter == SAMPLE_TIME);

    assign serial_out = data_sequence[bit_counter];

    // clock counter, bit counter, and adding the start/stop bits to the sequence
    always @(posedge clk)
    begin
        counter <= (reset) || (data_in_ready && data_in_valid) || (counter == SYMBOL_EDGE_TIME-1) ? 11'b0 : (processing) ? counter + 1 : counter;
        bit_counter <= (reset) || (data_in_ready && data_in_valid) ? 4'b0 : (counter == SYMBOL_EDGE_TIME-1) ? bit_counter + 1 : bit_counter;
        data_sequence <= (reset) ? 10'b0 : data_sequence;
    end

    // take the serial data in
    always @(posedge clk)
    begin
        if (counter == 11'b0)
        begin
            data_sequence = {1'b1, data_in, 1'b0};
        end
    end

    // give the ready signal out
    always @(posedge clk)
    begin
        processing <= (reset || bit_counter == 10) || (data_in_ready && data_in_valid) ? 1'b0 : 1'b1;
    end

    // Remove these assignments when implementing this module
    // assign serial_out = 1'b0;
    // assign data_in_ready = 1'b0;

    */

endmodule
