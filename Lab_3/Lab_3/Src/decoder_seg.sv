module decoder_seg (
    input logic [3:0] data_in,
    output logic [6:0] seg 
);
    // Internal signals for readability [cite: 2, 26, 50]
    logic D, C, B, A;
    assign {D, C, B, A} = data_in;

    // Segment Logic: 0 = ON, 1 = OFF (Common Anode) [cite: 3, 27, 51]
    assign seg[6] = (~D & ~C & ~B &  A) | (~D &  C & ~B & ~A) | ( D &  C & ~B &  A) | ( D & ~C &  B &  A); // Seg A
    assign seg[5] = (~D &  C & ~B &  A) | (~D &  C &  B & ~A) | ( D &  C &  B) | ( D & ~C &  B &  A);        // Seg B
    assign seg[4] = (~D & ~C &  B & ~A) | ( D &  C &  B) | ( D &  C & ~B);                                 // Seg C
    assign seg[3] = (~D & ~C & ~B &  A) | (~D &  C & ~B & ~A) | (~D &  C &  B &  A) | ( D & ~C &  B & ~A) | ( D &  C &  B &  A); // Seg D
    assign seg[2] = (~D & ~C & ~B &  A) | (~D & ~C &  B &  A) | (~D &  C & ~B & ~A) | (~D &  C & ~B &  A) | (~D &  C &  B &  A) | ( D & ~C & ~B &  A); // Seg E
    assign seg[1] = (~D & ~C & ~B &  A) | (~D & ~C &  B & ~A) | (~D & ~C &  B &  A) | (~D &  C &  B &  A) | ( D &  C & ~B &  A); // Seg F
    assign seg[0] = (~D & ~C & ~B & ~A) | (~D & ~C & ~B &  A) | (~D &  C &  B &  A) | ( D &  C & ~B & ~A); // Seg G

endmodule