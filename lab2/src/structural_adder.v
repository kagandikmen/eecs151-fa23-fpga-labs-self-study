// Modified:    2023-12-29
// Status:      works fine

module structural_adder (
    input [13:0] a,
    input [13:0] b,
    output [14:0] sum
);
    // TODO: Your implementation here.
    // TODO: Remove the assign statement below once you write your own RTL.
    
    wire [13:0] cout_ac, sum_ac;
    genvar i;

    full_adder first_adder (.a(a[0]), .b(b[0]), .carry_in(1'b0), .sum(sum_ac[0]), .carry_out(cout_ac[0]));

    generate
        for(i = 1; i < 14; i = i + 1)
        begin: adder_units
            full_adder other_adders (.a(a[i]), .b(b[i]), .carry_in(cout_ac[i-1]), .sum(sum_ac[i]), .carry_out(cout_ac[i]));
        end
    endgenerate

    assign sum = {cout_ac[13], sum_ac[13:0]};
    
    // assign sum = 15'd0;
endmodule
