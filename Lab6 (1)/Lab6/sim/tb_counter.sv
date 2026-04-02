`timescale 1ns/1ps

module tb_counter;

logic clk;
logic rst;
logic mode;
logic [3:0] count;
logic carry;

configurable_counter uut (
    .clk(clk),
    .rst(rst),
    .mode(mode),
    .count(count),
    .carry(carry)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    mode = 0;

    #20;
    rst = 0;

    mode = 0;
    #400;

    rst = 1;
    #20;
    rst = 0;
    mode = 1;

    #400;

    $stop;
end

endmodule