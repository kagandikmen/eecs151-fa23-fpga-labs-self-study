// Modified:    2023-12-29
// Status:      works fine

module full_adder (
    input a,
    input b,
    input carry_in,
    output sum,
    output carry_out
);
    // TODO: Insert your RTL here to calculate the sum and carry out bits.
    // TODO: Remove these assign statements once you write your own RTL.

    assign sum = a ^ b ^ carry_in;
    assign carry_out = (carry_in && (a ^ b)) || (a && b);

    // assign sum = 1'b0;
    // assign carry_out = 1'b0;
endmodule
