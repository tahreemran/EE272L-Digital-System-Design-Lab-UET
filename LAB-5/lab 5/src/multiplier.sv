/*
 * C=3 Constant Multiplier
 * Computes P = 3 * X using log shifters and ripple carry adder
 *
 * 3*X = (X << 1) + (X << 0) = 2X + X
 *
 * Shifter 0: a = 2'b01 → shift left by 1 → 2X
 * Shifter 1: a = 2'b00 → shift left by 0 → X
 * Adder: 2X + X = 3X
 */
module multiplier
(
    input  logic [3:0] x,
    output logic [3:0] p
);

    logic [3:0] shifted0;    // 2X  (X shifted left by 1)
    logic [3:0] shifted1;    // X   (X shifted left by 0)
    logic       cout_unused; // overflow carry — ignored

    // Shifter 0: shift X left by 1
    log_shifter s0 (
        .x(x),
        .a(2'b01),
        .y(shifted0)
    );

    // Shifter 1: shift X left by 0 (passthrough)
    log_shifter s1 (
        .x(x),
        .a(2'b00),
        .y(shifted1)
    );

    // Adder: 2X + X
    ripple_carry adder (
        .a(shifted0),
        .b(shifted1),
        .c_in(1'b0),
        .sum(p),
        .c_out(cout_unused)
    );

endmodule