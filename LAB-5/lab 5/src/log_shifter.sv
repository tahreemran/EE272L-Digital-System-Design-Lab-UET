/*
 * 4-bit Logarithmic Left Shifter
 * Structural implementation using mux2to1
 * Shift amount: a[1:0] where a[1]=S1 (MSB), a[0]=S0 (LSB)
 *
 * Stage 1 (S0): shifts by 0 or 1
 * Stage 2 (S1): shifts by 0 or 2
 * Combined:     shifts by 0,1,2,3
 */
module log_shifter
(
    input  logic [3:0] x,
    input  logic [1:0] a,
    output logic [3:0] y
);

    // Intermediate wires between Stage 1 and Stage 2
    logic [3:0] stage1;

    // ---- Stage 1: controlled by a[0] (S0) ----
    // If a[0]=0: pass through (no shift)
    // If a[0]=1: shift left by 1 (LSB gets 0)

    // stage1[0]: choose between X[0] and 0
    mux2to1 m0 (
        .in0(x[0]),
        .in1(1'b0),
        .sel(a[0]),
        .out(stage1[0])
    );

    // stage1[1]: choose between X[1] and X[0]
    mux2to1 m1 (
        .in0(x[1]),
        .in1(x[0]),
        .sel(a[0]),
        .out(stage1[1])
    );

    // stage1[2]: choose between X[2] and X[1]
    mux2to1 m2 (
        .in0(x[2]),
        .in1(x[1]),
        .sel(a[0]),
        .out(stage1[2])
    );

    // stage1[3]: choose between X[3] and X[2]
    mux2to1 m3 (
        .in0(x[3]),
        .in1(x[2]),
        .sel(a[0]),
        .out(stage1[3])
    );

    // ---- Stage 2: controlled by a[1] (S1) ----
    // If a[1]=0: pass through (no shift)
    // If a[1]=1: shift left by 2 (two LSBs get 0)

    // y[0]: choose between stage1[0] and 0
    mux2to1 m4 (
        .in0(stage1[0]),
        .in1(1'b0),
        .sel(a[1]),
        .out(y[0])
    );

    // y[1]: choose between stage1[1] and 0
    mux2to1 m5 (
        .in0(stage1[1]),
        .in1(1'b0),
        .sel(a[1]),
        .out(y[1])
    );

    // y[2]: choose between stage1[2] and stage1[0]
    mux2to1 m6 (
        .in0(stage1[2]),
        .in1(stage1[0]),
        .sel(a[1]),
        .out(y[2])
    );

    // y[3]: choose between stage1[3] and stage1[1]
    mux2to1 m7 (
        .in0(stage1[3]),
        .in1(stage1[1]),
        .sel(a[1]),
        .out(y[3])
    );

endmodule