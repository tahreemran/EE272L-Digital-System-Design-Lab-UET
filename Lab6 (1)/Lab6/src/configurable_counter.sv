module configurable_counter (
    input  logic clk,
    input  logic rst,
    input  logic mode,
    output logic [3:0] count,
    output logic carry
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 4'd0;
        carry <= 0;
    end
    else begin
        if (count == 4'd15) begin
            carry <= 1;
            if (mode == 1'b0)
                count <= 4'd0;
            else
                count <= 4'd15;
        end
        else begin
            count <= count + 1;
            carry <= 0;
        end
    end
end

endmodule