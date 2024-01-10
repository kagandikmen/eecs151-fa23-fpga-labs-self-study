// Author:      Kagan Dikmen
// Modified:    2024-01-10
// Status:      works fine (all the basic tests passed, assertions work too)

module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 32,
    parameter POINTER_WIDTH = $clog2(DEPTH)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [WIDTH-1:0] din,
    output full,

    // Read side
    input rd_en,
    output [WIDTH-1:0] dout,
    output empty
);

    assign dout = dout_buffer;
    assign empty = empty_buffer;
    assign full = full_buffer;
    assign active = ~rst;

    integer i;

    reg [WIDTH-1:0] dout_buffer;
    reg empty_buffer, full_buffer;
    reg [WIDTH-1:0] memory [DEPTH-1:0];
    reg [POINTER_WIDTH-1:0] write_pointer;
    reg [POINTER_WIDTH-1:0] read_pointer;

    // reset signal
    always @(posedge clk)
    begin
        if (rst)
        begin
            empty_buffer <= 1'b1;
            dout_buffer <= 'b0;
            full_buffer <= 1'b0;
            for(i = 0; i < DEPTH; i = i + 1)
            begin
                memory[i] <= 'b0;
            end
            read_pointer <= 'b0;
            write_pointer <= 'b0;
        end
    end
    

    // synchronous write and read
    always @(posedge clk)
    begin

        // synchronous write
        if (active && !full &&  wr_en)
        begin
            memory[write_pointer] <= din;
            write_pointer <= write_pointer + 1;
        end
    

        // synchronous read
        if (active && !empty && rd_en)
        begin
            dout_buffer <= memory[read_pointer];
            memory[read_pointer] <= 'b0;
            read_pointer <= read_pointer + 1;
        end
    

        // full signal
        if (wr_en && !full && (write_pointer + 1) % 8 == read_pointer)
        begin
            // $display("Mugla at time: %t ns with wr_en: %b, full value: %b, write_pointer: %d, read_pointer: %d.", $realtime/1000, wr_en, full, write_pointer, read_pointer);
            full_buffer = 1'b1;
        end
        else if (rd_en && full && write_pointer == read_pointer)
        begin
            // $display("Aydin at time: %t ns with wr_en: %b, full value: %b, write_pointer: %d, read_pointer: %d.", $realtime/1000, wr_en, full, write_pointer, read_pointer);
            full_buffer = 1'b0;
        end
        else
        begin
            // $display("Izmir at time: %t ns with wr_en: %b, full value: %b, write_pointer: %d, read_pointer: %d.", $realtime/1000, wr_en, full, write_pointer, read_pointer);
        end


        // empty signal
        if (rd_en && !empty && (read_pointer + 1) % 8 == write_pointer)
        begin
            empty_buffer = 1'b1;
        end
        else if (wr_en && empty && read_pointer == write_pointer)
        begin
            empty_buffer = 1'b0;
        end

    end

    write_pointer_assertion:
    assert property (@(posedge clk) disable iff (rst) (full == 1) |=> (write_pointer == $past(write_pointer))) 
        else $error("Error: write_pointer changes although full==1 at time: %t ns!", $realtime/1000);


    property read_pointer_stable_while_empty;
        @(posedge clk) disable iff (rst)
        (empty == 1) |=> (read_pointer == $past(read_pointer));
    endproperty

    read_pointer_assertion:
    assert property (read_pointer_stable_while_empty)
        else $error("Error: read_pointer changes although empty==1 at time: %t ns!", $realtime/1000);


    property reset_conditions;
        @(posedge clk)
        (rst == 1) |=> ((read_pointer == 0) && (write_pointer == 0) && !full);
    endproperty

    reset_assertion:
    assert property (reset_conditions)
        else $error("Reset conditions are violated at time: %t ns!", $realtime/1000);
    



    // AN OLD IMPLEMENTATION ATTEMPT

    // is the memory empty?
    /*
    always @(posedge clk)
    begin
        if (write_pointer + 1 == read_pointer)
        begin 
            empty_buffer <= 1'b1;
        end
        else
        begin
            empty_buffer <= 1'b0;
        end
    end
    */


    // is the memory full?
    /*
    always @(posedge clk)
    begin
        if (read_pointer + 1 == write_pointer)
        begin 
            full_buffer <= 1'b1;
        end
        else
        begin
            full_buffer <= 1'b0;
        end
    end
    */
    

    
endmodule
