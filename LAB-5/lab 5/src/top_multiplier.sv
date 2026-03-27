/*
 * Top Module: C=3 Constant Multiplier with 7-Segment Display
 *
 * Inputs:
 *   x[3:0]  → SW3, SW2, SW1, SW0
 *   sel[2:0] → SW6, SW5, SW4  (set to 3'b111 = AN7)
 *
 * Outputs:
 *   seg[6:0] → CA, CB, CC, CD, CE, CF, CG
 *   an[7:0]  → AN7 to AN0
 */
module top_multiplier
(
    input  logic [3:0] x,
    input  logic [2:0] sel,
    output logic [6:0] seg,
    output logic [7:0] an
);

    logic [3:0] product;

    // Step 1: compute 3*x
    multiplier mult (
        .x(x),
        .p(product)
    );

    // Step 2: decode product to 7-segment
    seg_decoder sd (
        .result(product),
        .seg(seg)
    );

    // Step 3: select which display to light up
    an_decoder ad (
        .sel(sel),
        .an(an)
    );

endmodule