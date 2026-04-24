/*
 * Testbench: edge_detector
 *
 * Berkeley Lab 3 spec:
 *   "The edge detector testbench tests that your edge_detector outputs a
 *    1 cycle wide pulse when its corresponding input transitions from 0 to 1."
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

`timescale 1ns/1ns

module edge_detector_tb;

    localparam WIDTH = 1;
    localparam CLK_PERIOD = 8;

    logic             clk;
    logic [WIDTH-1:0] signal_in;
    logic [WIDTH-1:0] pulse_out;

    edge_detector #(.WIDTH(WIDTH)) dut (
        .clk       (clk),
        .signal_in (signal_in),
        .pulse_out (pulse_out)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    task wait_clocks;
        input [7:0] n;
        repeat (n) @(posedge clk);
    endtask

    integer failed  = 0;
    integer pulse_count;
    integer i;

    initial begin
        signal_in = 0;
        wait_clocks(3);

        // --- Test 1: Single rising edge produces exactly 1 pulse ---
        $display("Test 1: Rising edge -> 1-cycle pulse");
        signal_in = 1;
        @(posedge clk); #1;
        assert(pulse_out == 1) else begin
            $display("FAIL: pulse_out should be 1 on first cycle after rise");
            failed++;
        end

        @(posedge clk); #1;
        assert(pulse_out == 0) else begin
            $display("FAIL: pulse_out should be 0 on second cycle (held high)");
            failed++;
        end
        if (!failed) $display("PASS: Got 1-cycle pulse on rising edge");

        // --- Test 2: Long press = only 1 pulse (held for 20 cycles) ---
        $display("Test 2: Long press (20 cycles) -> still only 1 pulse total");
        signal_in = 0;
        wait_clocks(3);
        pulse_count = 0;
        signal_in = 1;
        for (i = 0; i < 20; i = i + 1) begin
            @(posedge clk); #1;
            if (pulse_out) pulse_count = pulse_count + 1;
        end
        signal_in = 0;
        assert(pulse_count == 1) else begin
            $display("FAIL: Long press produced %0d pulses, expected 1", pulse_count);
            failed++;
        end
        if (pulse_count == 1) $display("PASS: Long press produced exactly 1 pulse");

        // --- Test 3: Two separate presses = 2 pulses ---
        $display("Test 3: Two presses -> 2 pulses");
        wait_clocks(3);
        pulse_count = 0;

        // Press 1
        signal_in = 1;
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk); #1;
            if (pulse_out) pulse_count = pulse_count + 1;
        end
        signal_in = 0;
        wait_clocks(5);

        // Press 2
        signal_in = 1;
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk); #1;
            if (pulse_out) pulse_count = pulse_count + 1;
        end
        signal_in = 0;

        assert(pulse_count == 2) else begin
            $display("FAIL: Two presses produced %0d pulses, expected 2", pulse_count);
            failed++;
        end
        if (pulse_count == 2) $display("PASS: Two presses produced exactly 2 pulses");

        // Summary
        if (failed == 0)
            $display("\nAll edge_detector tests PASSED.");
        else
            $display("\n%0d edge_detector test(s) FAILED.", failed);

        $finish;
    end

endmodule
