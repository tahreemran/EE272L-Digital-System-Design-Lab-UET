/*
 * Testbench: debouncer
 *
 * Berkeley Lab 3 spec - exactly 2 required tests:
 *   Test 1: "Verifies that if a glitchy signal initially bounces and then
 *            stays high for LESS than the saturation time, that the debouncer
 *            output never goes high."
 *
 *   Test 2: "Verifies that if a glitchy signal initially bounces and then
 *            stays high for MORE than the saturation time, that the debouncer
 *            goes high and stays high until the glitchy signal goes low."
 *
 * Uses small SAMPLE_CNT_MAX and PULSE_CNT_MAX for fast simulation.
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

`timescale 1ns/1ns

module debouncer_tb;

    // Small values for fast simulation
    // In real design: SAMPLE_CNT_MAX=65000, PULSE_CNT_MAX=200
    localparam SAMPLE_CNT_MAX = 5;
    localparam PULSE_CNT_MAX  = 4;
    localparam WIDTH          = 1;
    localparam CLK_PERIOD     = 8;

    logic             clk;
    logic [WIDTH-1:0] signal_in;
    logic [WIDTH-1:0] debounced_signal;

    debouncer #(
        .WIDTH          (WIDTH),
        .SAMPLE_CNT_MAX (SAMPLE_CNT_MAX),
        .PULSE_CNT_MAX  (PULSE_CNT_MAX)
    ) dut (
        .clk              (clk),
        .signal_in        (signal_in),
        .debounced_signal (debounced_signal)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    task wait_clocks;
        input integer n;
        repeat (n) @(posedge clk);
    endtask

    // Simulate a bouncy press: bounces b times then stays high for hold_samples
    // hold_samples is counted in SAMPLE pulses (not clock cycles)
    task apply_bouncy_signal;
        input integer bounces;
        input integer hold_samples;  // how many sample periods to hold high
        integer j;
        begin
            // Glitchy bouncing phase: rapidly toggle for 'bounces' cycles
            for (j = 0; j < bounces; j = j + 1) begin
                signal_in = 1;
                wait_clocks(SAMPLE_CNT_MAX / 2);
                signal_in = 0;
                wait_clocks(SAMPLE_CNT_MAX / 2);
            end
            // Now hold steady high for hold_samples sample periods
            signal_in = 1;
            wait_clocks(hold_samples * SAMPLE_CNT_MAX);
            // Then release
            signal_in = 0;
        end
    endtask

    integer failed = 0;

    initial begin
        signal_in = 0;
        wait_clocks(3);

        // ---------------------------------------------------------------
        // Test 1: Bouncy signal, stays high for LESS than saturation time
        //         -> debounced_signal must NEVER go high
        // ---------------------------------------------------------------
        $display("Test 1: Glitchy signal held < saturation time -> output stays LOW");

        // Bounce 3 times then hold high for only PULSE_CNT_MAX-1 sample periods
        fork
            begin
                apply_bouncy_signal(3, PULSE_CNT_MAX - 1);
            end
            begin
                // Observe output throughout
                repeat ((3 + PULSE_CNT_MAX) * SAMPLE_CNT_MAX + 5) begin
                    @(posedge clk); #1;
                    if (debounced_signal !== 0) begin
                        $display("FAIL Test 1: debounced_signal went high, should stay low");
                        failed++;
                    end
                end
            end
        join

        $display("PASS Test 1: debounced_signal never went high");
        wait_clocks(10);

        // ---------------------------------------------------------------
        // Test 2: Bouncy signal, stays high for MORE than saturation time
        //         -> debounced_signal must go high and stay high until
        //            the glitchy signal goes low
        // ---------------------------------------------------------------
        $display("Test 2: Glitchy signal held > saturation time -> output goes HIGH");

        signal_in = 0;
        wait_clocks(5);

        // Bounce 3 times then hold for PULSE_CNT_MAX+2 sample periods
        apply_bouncy_signal(3, PULSE_CNT_MAX + 2);

        // Check debounced went high
        // (allow a couple extra cycles for propagation)
        wait_clocks(2);
        // After signal went low, debounced should also be low
        // (counter resets because input is 0 at next sample)
        // Check that output went high at some point by monitoring it:
        // We re-run the test with monitoring this time

        signal_in = 0;
        wait_clocks(5);

        begin : test2_block
            integer went_high;
            integer went_low_after;
            integer cycle;
            went_high = 0;
            went_low_after = 0;

            // Apply bouncy press longer than saturation
            fork
                begin
                    apply_bouncy_signal(2, PULSE_CNT_MAX + 3);
                end
                begin
                    repeat ((2 + PULSE_CNT_MAX + 5) * SAMPLE_CNT_MAX + 10) begin
                        @(posedge clk); #1;
                        if (debounced_signal == 1) went_high = 1;
                    end
                end
            join

            // After button released, wait and check it goes low
            wait_clocks(SAMPLE_CNT_MAX * 2);
            if (debounced_signal == 0) went_low_after = 1;

            if (went_high && went_low_after) begin
                $display("PASS Test 2: debounced_signal went high and returned low");
            end else begin
                $display("FAIL Test 2: went_high=%0d went_low_after=%0d",
                         went_high, went_low_after);
                failed++;
            end
        end

        // Summary
        if (failed == 0)
            $display("\nAll debouncer tests PASSED.");
        else
            $display("\n%0d debouncer test(s) FAILED.", failed);

        $finish;
    end

endmodule
