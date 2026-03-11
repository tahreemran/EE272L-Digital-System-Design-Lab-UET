module binary_to_bcd_tb();
    logic [4:0] In;
    logic [7:0] y;

    binary_to_bcd MEA (
        .In(In),
        .y(y)
    );

    initial begin 
        // Console Header
        $display("Time\t Input(Dec) \t Input(Bin) \t Output(BCD)");

        In = 5'b00000; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b00001; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b00010; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b00011; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b00100; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b00101; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b00110; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b00111; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b01000; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b01001; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        
        // Transition point (9 to 10)
        In = 5'b01010; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b01011; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b01100; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b01101; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b01110; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b01111; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b10000; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b10001; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b10010; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b10011; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);

        In = 5'b10100; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b10101; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b10110; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b10111; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b11000; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b11001; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b11010; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b11011; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b11100; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b11101; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b11110; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);
        In = 5'b11111; #10; $display("%0t\t %d \t\t %b \t\t %h", $time, In, In, y);

        $display("Simulation Finished Successfully!");
        $stop; 
    end

endmodule
