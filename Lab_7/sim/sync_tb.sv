/*
 * Testbench: synchronizer
 * Verifies that async signals are correctly captured after 2 clock cycles.
 * Uses Berkeley-style fork/join and task constructs.
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

`timescale 1ns/1ns

module sync_tb;

    localparam WIDTH = 1;
    localparam CLK_PERIOD = 8;   // 125 MHz -> 8 ns period

    logic             clk;
    logic [WIDTH-1:0] async_in;
    logic [WIDTH-1:0] sync_out;

    // DUT
    synchronizer #(.WIDTH(WIDTH)) dut (
        .clk      (clk),
        .async_in (async_in),
        .sync_out (sync_out)
    );

    // Clock generation: 125 MHz
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Task: wait N rising edges
    task wait_for_n_clocks;
        input [7:0] n;
        repeat (n) @(posedge clk);
    endtask

    integer failed = 0;

    initial begin
        async_in = 0;

        // Wait a few cycles with input low
        wait_for_n_clocks(3);
        assert(sync_out == 0)
            else begin $display("FAIL: sync_out should be 0 at start"); failed++; end

        // Drive input high asynchronously (between clock edges)
        #(CLK_PERIOD/4);
        async_in = 1;

        // After 1 rising edge: FF1 captures it, sync_out still 0
        @(posedge clk); #1;
        assert(sync_out == 0)
            else begin $display("FAIL: sync_out should still be 0 after 1 edge"); failed++; end

        // After 2nd rising edge: FF2 captures it, sync_out now 1
        @(posedge clk); #1;
        assert(sync_out == 1)
            else begin $display("FAIL: sync_out should be 1 after 2 edges"); failed++; end
        $display("PASS: sync_out correctly went high after 2 clock edges");

        // Drive input low
        async_in = 0;
        @(posedge clk); #1;
        assert(sync_out == 1)
            else begin $display("FAIL: sync_out should still be 1"); failed++; end

        @(posedge clk); #1;
        assert(sync_out == 0)
            else begin $display("FAIL: sync_out should be 0 after input went low"); failed++; end
        $display("PASS: sync_out correctly went low after 2 clock edges");

        // Summary
        if (failed == 0)
            $display("\nAll synchronizer tests PASSED.");
        else
            $display("\n%0d synchronizer test(s) FAILED.", failed);

        $finish;
    end

endmodule
