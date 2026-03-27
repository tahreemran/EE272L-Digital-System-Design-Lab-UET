/*
 * 1-bit Full Adder
 * sum  = a XOR b XOR cin
 * cout = (a AND b) OR (a AND cin) OR (b AND cin)
 */
module full_adder
(
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);

endmodule