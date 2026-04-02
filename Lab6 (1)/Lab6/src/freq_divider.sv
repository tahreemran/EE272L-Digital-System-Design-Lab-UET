module freq_divider (
    input  logic clk,
    input  logic rst,
    output logic slow_clk
);

logic [25:0] counter;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        counter  <= 0;
        slow_clk <= 0;
    end
    else begin
        counter <= counter + 1;
        slow_clk <= counter[25];
    end
end

endmodule