/*
 * Anode Decoder
 * Selects which 7-segment display to enable
 * Common anode: active LOW (0 = display ON)
 * sel=7 means use display AN7 (leftmost)
 */
module an_decoder
(
    input  logic [2:0] sel,
    output logic [7:0] an
);

    always_comb begin
        case (sel)
            3'd0: an = 8'b11111110; // AN0
            3'd1: an = 8'b11111101; // AN1
            3'd2: an = 8'b11111011; // AN2
            3'd3: an = 8'b11110111; // AN3
            3'd4: an = 8'b11101111; // AN4
            3'd5: an = 8'b11011111; // AN5
            3'd6: an = 8'b10111111; // AN6
            3'd7: an = 8'b01111111; // AN7
            default: an = 8'b11111111; // all off
        endcase
    end

endmodule