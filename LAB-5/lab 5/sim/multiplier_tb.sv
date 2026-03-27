module multiplier_tb;

    logic [3:0] x1;
    logic [3:0] p1;

    multiplier UUT (
        .x(x1),
        .p(p1)
    );

    initial begin
        x1 = 4'd0; #10;
        $display("X=%0d, 3X=%0d, Got=%0d", x1, 0, p1);

        x1 = 4'd1; #10;
        $display("X=%0d, 3X=%0d, Got=%0d", x1, 3, p1);

        x1 = 4'd2; #10;
        $display("X=%0d, 3X=%0d, Got=%0d", x1, 6, p1);

        x1 = 4'd3; #10;
        $display("X=%0d, 3X=%0d, Got=%0d", x1, 9, p1);

        x1 = 4'd4; #10;
        $display("X=%0d, 3X=%0d, Got=%0d", x1, 12, p1);

        x1 = 4'd5; #10;
        $display("X=%0d, 3X=%0d, Got=%0d", x1, 15, p1);

        $stop;
    end

endmodule