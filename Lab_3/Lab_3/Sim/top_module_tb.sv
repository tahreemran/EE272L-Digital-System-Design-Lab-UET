module decoder_tb;

  logic [2:0] a, b, sel;
  logic c_in;
  logic [6:0] seg;
  logic [7:0] an;

  top_adder_decoder MEA (
    .a(a),
    .b(b),
    .c_in(c_in),
    .sel(sel),
    .seg(seg),
    .an(an)
  );

  initial begin
    $display("a\tb\tc_in\tseg\tan");

    // Test Case 1: 3 + 4 + 0 = 7. Expected seg = 0001111
    a = 3; b = 4; c_in = 0; sel = 3;

    #10;
    $display("%b\t%b\t%b\t%b\t%b", a, b, c_in, seg, an);

    if (seg != 7'b0001111)
      $display("ERROR: seg_output_incorrect");
    else
      $display("PASS: seg_output_correct");

    if (an != 8'b01111111)
      $display("ERROR: an_output_incorrect");
    else
      $display("PASS: an_output_correct");

    $display("Now_its_your_turn! Try other input combinations.");
    $stop;
  end
endmodule