module hex7seg_decoder(
    input [3:0] dec,
    output [6:0] seg
);
assign seg =
       (dec == 4'h0) ? 7'b0000001 :
       (dec == 4'h1) ? 7'b1001111 :
       (dec == 4'h2) ? 7'b0010010 :
       (dec == 4'h3) ? 7'b0000110 :
       (dec == 4'h4) ? 7'b1001100 :
       (dec == 4'h5) ? 7'b0100100 :
       (dec == 4'h6) ? 7'b0100000 :
       (dec == 4'h7) ? 7'b0001111 :
       (dec == 4'h8) ? 7'b0000000 :
       (dec == 4'h9) ? 7'b0000100 :
       (dec == 4'hA) ? 7'b0001000 :
       (dec == 4'hB) ? 7'b1100000 :
       (dec == 4'hC) ? 7'b0110001 :
       (dec == 4'hD) ? 7'b1000010 :
       (dec == 4'hE) ? 7'b0110000 :
                      7'b0111000;
endmodule