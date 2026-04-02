module display_mux (
    input  logic [2:0] sel,
    input  logic [3:0] digit0,
    input  logic [3:0] digit1,
    output logic [3:0] out
);

always_comb begin
    case (sel)
        3'd0: out = digit0;
        3'd1: out = digit1;
        default: out = 4'd0;
    endcase
end

endmodule