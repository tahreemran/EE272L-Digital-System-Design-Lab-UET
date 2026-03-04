module decoder_sel (
    input logic [2:0] sel,
    output logic [7:0] an
);
    logic S2, S1, S0;
    assign {S2, S1, S0} = sel; 

    // Active Low Anodes: 0 = ON, 1 = OFF
    assign an[0] = (S2 | S1 | S0);      // cite: 76
    assign an[1] = (S2 | S1 | ~S0);     // cite: 76
    assign an[2] = (S2 | ~S1 | S0);     // cite: 76
    assign an[3] = 1'b1;                 // cite: 79
    assign an[4] = 1'b1;                 // cite: 80
    assign an[5] = 1'b1;                 // cite: 80
    assign an[6] = 1'b1;                 // cite: 80
    assign an[7] = ~(~S2 & S1 & S0);     // cite: 78

endmodule