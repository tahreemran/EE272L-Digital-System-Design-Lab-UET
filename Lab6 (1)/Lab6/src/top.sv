module top (
    input  logic clk,
    input  logic rst,
    input  logic mode,
    output logic [7:0] LED,
    output logic [6:0] seg,
    output logic [7:0] AN
);

logic slow_clk;
logic [3:0] count0, count1;
logic carry0;
logic [2:0] sel;
logic [3:0] digit;

freq_divider fd (
    .clk(clk),
    .rst(rst),
    .slow_clk(slow_clk)
);

configurable_counter c0 (
    .clk(slow_clk),
    .rst(rst),
    .mode(mode),
    .count(count0),
    .carry(carry0)
);

configurable_counter c1 (
    .clk(slow_clk & carry0),
    .rst(rst),
    .mode(mode),
    .count(count1),
    .carry()
);

assign LED[3:0] = count0;
assign LED[7:4] = count1;

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        sel <= 0;
    else
        sel <= sel + 1;
end

display_mux mux (
    .sel(sel),
    .digit0(count0),
    .digit1(count1),
    .out(digit)
);

hex7seg_decoder h (
    .dec(digit),
    .seg(seg)
);

anode_decoder a (
    .sel(sel),
    .AN(AN)
);

endmodule