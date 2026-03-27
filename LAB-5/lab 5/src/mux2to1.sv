/*
 * 2-to-1 Multiplexer
 * Structural implementation using basic gates
 * out = (in0 AND NOT sel) OR (in1 AND sel)
 */
module mux2to1
(
    input  logic in0,
    input  logic in1,
    input  logic sel,
    output logic out
);

    logic not_sel;
    logic and0_out;
    logic and1_out;

    // Gate-level implementation
    not g0 (not_sel,  sel);
    and g1 (and0_out, in0, not_sel);
    and g2 (and1_out, in1, sel);
    or  g3 (out,      and0_out, and1_out);

endmodule