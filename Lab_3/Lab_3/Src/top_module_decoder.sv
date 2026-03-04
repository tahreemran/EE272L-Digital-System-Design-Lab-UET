module top_adder_decoder (
    input logic [2:0] a, b,
    input logic c_in,
    input logic [2:0] sel, 
    output logic [6:0] seg,
    output logic [7:0] an
);
    logic [2:0] sum;
    logic cout;
    logic [3:0] combined_result;

    // Instantiate your Ripple Carry Adder from Lab 2
    ripple_carry RCA (
        .a(a),
        .b(b),
        .c_in(c_in),
        .sum(sum),
        .c_out(cout)
    );

    assign combined_result = {cout, sum};

    // Instantiate Segment Decoder
    decoder_seg SEG_DEC (
        .data_in(combined_result),
        .seg(seg)
    );

    // Instantiate Anode Decoder
    decoder_sel AN_DEC (
        .sel(sel),
        .an(an)
    );

endmodule