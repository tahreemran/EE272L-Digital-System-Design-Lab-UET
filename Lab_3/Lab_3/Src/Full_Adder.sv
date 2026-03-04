module full_adder (
    input logic a,
    input logic b,
    input logic c_in,
    output logic sum,
    output logic c_out
);
    // Internal wires for intermediate signals
    wire w1, w2, w3, w4; 

    // Sum logic
    xor (w1, a, b); 
    xor (sum, w1, c_in); 

    // Carry-out logic
    and (w2, a, b); 
    and (w3, b, c_in); 
    and (w4, c_in, a); 
    or (c_out, w2, w3, w4); 

endmodule
