/*
 * 4-bit Ripple Carry Adder
 * Modified from Lab 2 (3-bit) to 4-bit
 * Structural: 4 full adders chained together
 */
module ripple_carry
(
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       c_in,
    output logic [3:0] sum,
    output logic       c_out
);

    // Internal carry wires between stages
    logic c1, c2, c3;

    // FA0: least significant bit
    full_adder fa0 (
        .a(a[0]),
        .b(b[0]),
        .cin(c_in),
        .sum(sum[0]),
        .cout(c1)
    );

    // FA1
    full_adder fa1 (
        .a(a[1]),
        .b(b[1]),
        .cin(c1),
        .sum(sum[1]),
        .cout(c2)
    );

    // FA2
    full_adder fa2 (
        .a(a[2]),
        .b(b[2]),
        .cin(c2),
        .sum(sum[2]),
        .cout(c3)
    );

    // FA3: most significant bit
    full_adder fa3 (
        .a(a[3]),
        .b(b[3]),
        .cin(c3),
        .sum(sum[3]),
        .cout(c_out)
    );

endmodule